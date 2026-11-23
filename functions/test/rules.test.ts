import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';

const AUTHOR = 'author';
const ME = 'me';
const OTHER = 'other';
const SPOT = 'spot1';

let env: RulesTestEnvironment;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-spotshare',
    firestore: {
      rules: readFileSync(resolve(__dirname, '../../../firestore.rules'), 'utf8'),
    },
  });
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'spots', SPOT), { title: 'Café', authorId: AUTHOR });
    await setDoc(doc(db, 'spots', SPOT, 'comments', 'mine'), {
      authorId: ME,
      text: 'Super',
      createdAt: new Date(),
    });
    await setDoc(doc(db, 'spots', SPOT, 'comments', 'theirs'), {
      authorId: OTHER,
      text: 'Bof',
      createdAt: new Date(),
    });
    await setDoc(doc(db, 'spots', SPOT, 'ratings', ME), {
      value: 4,
      updatedAt: new Date(),
    });
  });
});

const asMe = () => env.authenticatedContext(ME).firestore();
const ratingRef = (db: ReturnType<typeof asMe>, uid: string) =>
  doc(db, 'spots', SPOT, 'ratings', uid);
const comments = (db: ReturnType<typeof asMe>) =>
  collection(db, 'spots', SPOT, 'comments');
const comment = (text: string, authorId = ME) => ({
  authorId,
  text,
  createdAt: serverTimestamp(),
});

describe('spots', () => {
  it('autorise la lecture à un utilisateur connecté', async () => {
    await assertSucceeds(getDoc(doc(asMe(), 'spots', SPOT)));
  });

  it('refuse la lecture à un visiteur', async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'spots', SPOT)));
  });

  it('refuse toute écriture, même par son auteur', async () => {
    const db = env.authenticatedContext(AUTHOR).firestore();
    await assertFails(setDoc(doc(db, 'spots', 'new'), { title: 'X' }));
    await assertFails(updateDoc(doc(db, 'spots', SPOT), { title: 'Y' }));
    await assertFails(deleteDoc(doc(db, 'spots', SPOT)));
  });
});

describe('ratings', () => {
  const rating = (value: number, extra: object = {}) => ({
    value,
    updatedAt: serverTimestamp(),
    ...extra,
  });

  it('autorise à noter 5 sur sa propre note', async () => {
    await assertSucceeds(setDoc(ratingRef(asMe(), ME), rating(5)));
  });

  it('autorise à modifier sa note existante', async () => {
    await assertSucceeds(setDoc(ratingRef(asMe(), ME), rating(2)));
  });

  it('refuse de noter sous le document d\'un autre utilisateur', async () => {
    await assertFails(setDoc(ratingRef(asMe(), OTHER), rating(5)));
  });

  it('refuse une note de 0 ou de 6', async () => {
    await assertFails(setDoc(ratingRef(asMe(), ME), rating(0)));
    await assertFails(setDoc(ratingRef(asMe(), ME), rating(6)));
  });

  it('refuse une note non entière', async () => {
    await assertFails(setDoc(ratingRef(asMe(), ME), rating(3.5)));
  });

  it('refuse une clé en trop', async () => {
    await assertFails(setDoc(ratingRef(asMe(), ME), rating(5, { extra: 1 })));
  });

  it('refuse un updatedAt qui n\'est pas l\'heure serveur', async () => {
    await assertFails(
      setDoc(ratingRef(asMe(), ME), { value: 5, updatedAt: new Date(0) }),
    );
  });

  it('refuse à l\'auteur de noter son propre spot', async () => {
    const db = env.authenticatedContext(AUTHOR).firestore();
    await assertFails(setDoc(ratingRef(db, AUTHOR), rating(5)));
  });

  it('refuse la suppression d\'une note', async () => {
    await assertFails(deleteDoc(ratingRef(asMe(), ME)));
  });
});

describe('comments', () => {
  it('autorise un commentaire valide', async () => {
    await assertSucceeds(addDoc(comments(asMe()), comment('Génial !')));
  });

  it('autorise un commentaire de 500 caractères', async () => {
    await assertSucceeds(addDoc(comments(asMe()), comment('a'.repeat(500))));
  });

  it('refuse un authorId qui est celui d\'un autre', async () => {
    await assertFails(addDoc(comments(asMe()), comment('Hello', OTHER)));
  });

  it('refuse un texte vide ou fait seulement d\'espaces', async () => {
    await assertFails(addDoc(comments(asMe()), comment('')));
    await assertFails(addDoc(comments(asMe()), comment('   \n ')));
  });

  it('refuse un texte de 501 caractères', async () => {
    await assertFails(addDoc(comments(asMe()), comment('a'.repeat(501))));
  });

  it('refuse une clé en trop ou un createdAt falsifié', async () => {
    await assertFails(
      addDoc(comments(asMe()), { ...comment('Hello'), extra: 1 }),
    );
    await assertFails(
      addDoc(comments(asMe()), {
        authorId: ME,
        text: 'Hello',
        createdAt: new Date(0),
      }),
    );
  });

  it('refuse toute modification', async () => {
    await assertFails(
      updateDoc(doc(asMe(), 'spots', SPOT, 'comments', 'mine'), { text: 'Edit' }),
    );
  });

  it('autorise à supprimer son commentaire', async () => {
    await assertSucceeds(deleteDoc(doc(asMe(), 'spots', SPOT, 'comments', 'mine')));
  });

  it('refuse de supprimer le commentaire d\'un autre', async () => {
    await assertFails(
      deleteDoc(doc(asMe(), 'spots', SPOT, 'comments', 'theirs')),
    );
  });

  it('autorise la lecture à un connecté et la refuse à un visiteur', async () => {
    await assertSucceeds(getDoc(doc(asMe(), 'spots', SPOT, 'comments', 'mine')));
    const db = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'spots', SPOT, 'comments', 'mine')));
  });
});

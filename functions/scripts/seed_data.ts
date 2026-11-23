export type Media = {
  type: 'photo' | 'video';
  url: string;
  thumbnailUrl?: string;
  durationMs?: number;
};

export type SeedSpot = {
  id: string;
  title: string;
  description: string;
  category: string;
  address: string;
  lat: number;
  lng: number;
  authorId: string;
  tags: string[];
  media: Media[];
  commentCount: number;
};

// Clips libres : MDN en CC0, Big Buck Bunny en CC-BY (Blender Foundation) ; durées mesurées avec ffprobe.
const MDN = 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos';
const BBB = 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4';
const photo = (id: number): Media => ({
  type: 'photo',
  url: `https://picsum.photos/id/${id}/1600/1200`,
});
const video = (url: string, durationMs: number, thumb: number): Media => ({
  type: 'video',
  url,
  thumbnailUrl: `https://picsum.photos/id/${thumb}/800/600`,
  durationMs,
});

export const users = [
  { id: 'seed-user-1', displayName: 'Camille Durand', bio: 'Chasseuse de cafés et de coins calmes à Paris.' },
  { id: 'seed-user-2', displayName: 'Yanis Benali', bio: 'Photographe amateur, toujours en quête du meilleur point de vue.' },
  { id: 'seed-user-3', displayName: 'Léa Martin', bio: 'Street art, balades et bonnes tables.' },
];

export const seedSpots: SeedSpot[] = [
  {
    id: 'seed-spot-1',
    title: 'Café de Flore',
    description: 'Terrasse mythique de Saint-Germain-des-Prés. Idéal pour un café crème en observant la vie du quartier.',
    category: 'cafe',
    address: '172 Boulevard Saint-Germain, 75006 Paris',
    lat: 48.8541,
    lng: 2.3326,
    authorId: 'seed-user-1',
    tags: ['terrasse', 'historique', 'café'],
    media: [photo(1060), photo(1080)],
    commentCount: 25,
  },
  {
    id: 'seed-spot-2',
    title: 'Parvis du Sacré-Cœur',
    description: 'Vue panoramique sur tout Paris, magnifique au coucher du soleil. Venez tôt pour éviter la foule.',
    category: 'viewpoint',
    address: 'Parvis du Sacré-Cœur, 35 Rue du Chevalier de la Barre, 75018 Paris',
    lat: 48.8867,
    lng: 2.3431,
    authorId: 'seed-user-2',
    tags: ['panorama', 'coucher de soleil'],
    media: [video(`${MDN}/flower.mp4`, 5055, 1018), photo(1043)],
    commentCount: 8,
  },
  {
    id: 'seed-spot-3',
    title: 'Fresques de la rue Dénoyez',
    description: 'Une rue entière couverte de fresques qui changent sans cesse. Un musée à ciel ouvert à Belleville.',
    category: 'streetArt',
    address: 'Rue Dénoyez, 75020 Paris',
    lat: 48.8723,
    lng: 2.3809,
    authorId: 'seed-user-3',
    tags: ['fresques', 'belleville', 'gratuit'],
    media: [photo(1035), photo(1039), video(`${MDN}/friday.mp4`, 6166, 1025)],
    commentCount: 12,
  },
  {
    id: 'seed-spot-4',
    title: 'Chez Janou',
    description: 'Bistrot provençal réputé pour sa mousse au chocolat à volonté. Réservation conseillée le week-end.',
    category: 'restaurant',
    address: '2 Rue Roger Verlomme, 75003 Paris',
    lat: 48.8559,
    lng: 2.3656,
    authorId: 'seed-user-2',
    tags: ['bistrot', 'provençal', 'dessert'],
    media: [photo(1062)],
    commentCount: 5,
  },
  {
    id: 'seed-spot-5',
    title: 'Parc des Buttes-Chaumont',
    description: 'Collines, lac et petit temple perché : le parc le plus vallonné de Paris, parfait pour un pique-nique.',
    category: 'park',
    address: 'Rue Botzaris, 75019 Paris',
    lat: 48.8809,
    lng: 2.3828,
    authorId: 'seed-user-3',
    tags: ['pique-nique', 'nature', 'lac'],
    media: [video(BBB, 10000, 1015), photo(1018)],
    commentCount: 15,
  },
  {
    id: 'seed-spot-6',
    title: 'Passerelle Léopold-Sédar-Senghor',
    description: 'Passerelle piétonne sur la Seine face au musée d’Orsay, très agréable pour flâner en fin de journée.',
    category: 'other',
    address: 'Passerelle Léopold-Sédar-Senghor, 75007 Paris',
    lat: 48.8613,
    lng: 2.3237,
    authorId: 'seed-user-1',
    tags: ['seine', 'balade'],
    media: [photo(1067), photo(1070)],
    commentCount: 3,
  },
];

export const commentPool = [
  'Super endroit, je recommande vivement !',
  'Un peu cher mais ça vaut le détour.',
  'Très agréable en fin de journée.',
  'Y étais ce week-end, il y avait beaucoup de monde.',
  'Parfait pour une sortie entre amis.',
  'Belle découverte, merci pour le partage !',
  'Les photos ne rendent pas justice au lieu.',
  'Je reviendrai sans hésiter.',
  'Calme en semaine, plus animé le samedi.',
  'Accueil sympathique et cadre soigné.',
  'Un incontournable du quartier.',
  'Venez tôt si vous voulez avoir de la place.',
];

export const BASE_DATE = Date.UTC(2026, 9, 1, 10, 0, 0);
export const HOUR_MS = 3_600_000;

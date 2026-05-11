export interface PurchaseCard {
  id: string;
  title: string;
  price: number;
  type: 'want' | 'need';
  emoji: string;
}

export const PURCHASE_CARDS: PurchaseCard[] = [
  { id: '1', title: 'Sephora Haul', price: 67, type: 'want', emoji: '💄' },
  { id: '2', title: 'Quick Lunch', price: 12, type: 'need', emoji: '🥪' },
  { id: '3', title: 'Coachella Ticket', price: 1200, type: 'want', emoji: '🎡' },
  { id: '4', title: 'Phone Bill', price: 55, type: 'need', emoji: '📱' },
  { id: '5', title: 'Matching Sweatset', price: 85, type: 'want', emoji: '🧶' },
  { id: '6', title: 'Gas for Car', price: 40, type: 'need', emoji: '⛽' },
  { id: '7', title: 'Concert Merch', price: 45, type: 'want', emoji: '👕' },
  { id: '8', title: 'Rent Payment', price: 1400, type: 'need', emoji: '🏠' },
  { id: '9', title: 'Late Night Uber', price: 24, type: 'want', emoji: '🚗' },
  { id: '10', title: 'Weekly Groceries', price: 95, type: 'need', emoji: '🛒' },
  { id: '11', title: 'Coffee Run', price: 7, type: 'want', emoji: '☕' },
  { id: '12', title: 'Gym Membership', price: 45, type: 'need', emoji: '💪' },
  { id: '13', title: 'Streaming Sub', price: 15, type: 'want', emoji: '🎬' },
  { id: '14', title: 'Vitamins', price: 25, type: 'need', emoji: '💊' },
  { id: '15', title: 'DoorDash Dinner', price: 38, type: 'want', emoji: '🍕' },
];

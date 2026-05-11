import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Text, View, StyleSheet, Platform } from 'react-native';
import { BlurView } from 'expo-blur';
import { palette, radius, spacing, typography } from '../theme/tokens';

import SplashScreen from '../screens/SplashScreen';
import LoginScreen from '../screens/LoginScreen';
import BuddyPickerScreen from '../screens/BuddyPickerScreen';
import HomeScreen from '../screens/HomeScreen';
import QuestsScreen from '../screens/QuestsScreen';
import MoneyScreen from '../screens/MoneyScreen';
import SquadScreen from '../screens/SquadScreen';
import BuddyScreen from '../screens/BuddyScreen';
import QuestDetailScreen from '../screens/QuestDetailScreen';
import NegotiationScreen from '../screens/NegotiationScreen';
import FutureSelfScreen from '../screens/FutureSelfScreen';
import SwipeGameScreen from '../screens/SwipeGameScreen';

export type RootStackParamList = {
  Splash: undefined;
  Login: undefined;
  BuddyPicker: undefined;
  Main: undefined;
  QuestDetail: { questId: string };
  Negotiation: { questId: string };
  FutureSelf: undefined;
  SwipeGame: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator();

const TAB_META: Record<string, { label: string; emoji: string }> = {
  Home: { label: 'Home', emoji: '✦' },
  Quests: { label: 'Quests', emoji: '✧' },
  Money: { label: 'Money', emoji: '◐' },
  Squad: { label: 'Squad', emoji: '◇' },
  Buddy: { label: 'Buddy', emoji: '❀' },
};

function TabBarIcon({ name, focused }: { name: string; focused: boolean }) {
  const meta = TAB_META[name];
  return (
    <View style={styles.tabItem}>
      <Text style={[styles.tabEmoji, { color: focused ? palette.ink : palette.inkMuted }]}>{meta.emoji}</Text>
      <Text style={[styles.tabLabel, { color: focused ? palette.ink : palette.inkMuted }]}>{meta.label}</Text>
    </View>
  );
}

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarShowLabel: false,
        tabBarStyle: styles.tabBar,
        tabBarBackground: () => (
          <BlurView intensity={40} tint="light" style={[StyleSheet.absoluteFill, styles.tabBlur]} />
        ),
        tabBarIcon: ({ focused }) => <TabBarIcon name={route.name} focused={focused} />,
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Quests" component={QuestsScreen} />
      <Tab.Screen name="Money" component={MoneyScreen} />
      <Tab.Screen name="Squad" component={SquadScreen} />
      <Tab.Screen name="Buddy" component={BuddyScreen} />
    </Tab.Navigator>
  );
}

export function Navigation() {
  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false, contentStyle: { backgroundColor: 'transparent' } }}>
        <Stack.Screen name="Splash" component={SplashScreen} />
        <Stack.Screen name="Login" component={LoginScreen} />
        <Stack.Screen name="BuddyPicker" component={BuddyPickerScreen} />
        <Stack.Screen name="Main" component={MainTabs} />
        <Stack.Screen name="QuestDetail" component={QuestDetailScreen} options={{ presentation: 'modal' }} />
        <Stack.Screen name="Negotiation" component={NegotiationScreen} options={{ presentation: 'modal' }} />
        <Stack.Screen name="FutureSelf" component={FutureSelfScreen} options={{ presentation: 'modal' }} />
        <Stack.Screen name="SwipeGame" component={SwipeGameScreen} options={{ presentation: 'modal' }} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  tabBar: {
    position: 'absolute',
    bottom: Platform.OS === 'ios' ? 28 : 16,
    left: 20,
    right: 20,
    height: 72,
    paddingTop: 12,
    paddingBottom: 12,
    borderRadius: radius.pill,
    borderTopWidth: 0,
    backgroundColor: 'transparent',
    elevation: 0,
    shadowColor: palette.ink,
    shadowOpacity: 0.12,
    shadowRadius: 24,
    shadowOffset: { width: 0, height: 12 },
  },
  tabBlur: {
    borderRadius: radius.pill,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: palette.glassBorder,
    backgroundColor: 'rgba(255,255,255,0.55)',
  },
  tabItem: { alignItems: 'center', justifyContent: 'center', gap: 2 },
  tabEmoji: { fontSize: 18, fontWeight: '600' },
  tabLabel: { ...typography.caption, letterSpacing: 0.6 },
});

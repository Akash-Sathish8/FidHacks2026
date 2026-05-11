import React from 'react';
import Svg, { Path } from 'react-native-svg';
import { palette } from '../theme/tokens';

interface Props {
  values: number[];
  width?: number;
  height?: number;
  color?: string;
}

export function MiniChart({ values, width = 80, height = 28, color }: Props) {
  if (values.length < 2) return null;
  const min = Math.min(...values);
  const max = Math.max(...values);
  const range = max - min || 1;
  const stepX = width / (values.length - 1);
  const points = values.map((v, i) => {
    const x = i * stepX;
    const y = height - ((v - min) / range) * height;
    return `${x.toFixed(2)},${y.toFixed(2)}`;
  });
  const path = `M ${points.join(' L ')}`;
  const up = values[values.length - 1] >= values[0];
  const stroke = color ?? (up ? palette.mintDeep : palette.peachDeep);
  return (
    <Svg width={width} height={height}>
      <Path d={path} stroke={stroke} strokeWidth={2} fill="none" strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

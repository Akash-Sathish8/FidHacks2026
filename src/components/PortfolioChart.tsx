import React from 'react';
import { View, StyleSheet } from 'react-native';
import Svg, { Defs, LinearGradient, Path, Stop } from 'react-native-svg';
import { palette } from '../theme/tokens';

interface Props {
  series: number[];
  benchmarkSeries?: number[];
  width: number;
  height: number;
  baseline?: number;
}

export function PortfolioChart({ series, benchmarkSeries, width, height, baseline }: Props) {
  if (series.length < 2) return <View style={{ width, height }} />;

  const all = benchmarkSeries ? [...series, ...benchmarkSeries] : series;
  const min = Math.min(...all);
  const max = Math.max(...all);
  const range = max - min || 1;
  const stepX = width / (series.length - 1);

  const project = (vals: number[]) => {
    const pts = vals.map((v, i) => {
      const x = i * stepX;
      const y = height - ((v - min) / range) * height;
      return `${x.toFixed(2)},${y.toFixed(2)}`;
    });
    return `M ${pts.join(' L ')}`;
  };

  const main = project(series);
  const bench = benchmarkSeries ? project(benchmarkSeries.slice(0, series.length)) : null;
  const up = series[series.length - 1] >= series[0];
  const mainColor = up ? palette.mintDeep : palette.peachDeep;

  // Fill path: under the main line down to the bottom
  const lastX = (series.length - 1) * stepX;
  const fillPath = `${main} L ${lastX.toFixed(2)},${height} L 0,${height} Z`;

  return (
    <View style={[styles.wrap, { width, height }]}>
      <Svg width={width} height={height}>
        <Defs>
          <LinearGradient id="fill" x1="0" y1="0" x2="0" y2="1">
            <Stop offset="0" stopColor={mainColor} stopOpacity={0.28} />
            <Stop offset="1" stopColor={mainColor} stopOpacity={0} />
          </LinearGradient>
        </Defs>
        <Path d={fillPath} fill="url(#fill)" />
        {bench && (
          <Path d={bench} stroke={palette.inkMuted} strokeWidth={1.5} strokeDasharray="4,4" fill="none" />
        )}
        <Path d={main} stroke={mainColor} strokeWidth={2.5} fill="none" strokeLinecap="round" strokeLinejoin="round" />
      </Svg>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { backgroundColor: 'transparent' },
});

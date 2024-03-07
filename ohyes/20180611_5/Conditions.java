package com.pengkong.boatrace.simulation2;

import com.pengkong.boatrace.simulation.model.RaceEx;

public class Conditions {

	public Conditions() {
		// TODO Auto-generated constructor stub
	}

	public static boolean isRaceNoOk(RaceEx race) {
		return (race.raceInfo.no != 10 
				&& race.raceInfo.no != 11
				&& race.raceInfo.no != 12
				);
	}
	
	public static boolean isWindDirectionOk(RaceEx race) {
		return (race.raceInfo.windDirection.equals("5") 
				|| race.raceInfo.windDirection.equals("7")
				|| race.raceInfo.windDirection.equals("13")
				);
	}
	
	public static boolean isTrunOk(RaceEx race) {
		return (!race.setu.turn.equals("4") 
				&&  !race.setu.turn.equals("5")
				);
	}
	
	public static boolean isWeatherOk(RaceEx race) {
		return (race.raceInfo.weather.equals("晴") 
				||  race.raceInfo.weather.equals("曇り")
				);
	}
	
	public static boolean isWindOk(RaceEx race) {
		return (race.raceInfo.wind >= 2 
				&&  race.raceInfo.wind <= 3
				);
	}
	
	public static boolean isWaveOk(RaceEx race) {
		return ( (race.raceInfo.wave >= 1 && race.raceInfo.wave <= 3)  
				||  race.raceInfo.wave == 5 
				);
	}
	
	public static boolean isMotor2RankOk(RaceEx race) {
		return ( 
				race.calculatedInfo.motor2Rank.substring(5, 6).equals("3") 
				|| race.calculatedInfo.motor2Rank.substring(5, 6).equals("4") 
				);
	}
	
	public static boolean isHonmyo(RaceEx race, String betType) {
		boolean result = false;
		if (betType.equals("1T")) {
			result =  (
					(race.raceInfo2.aLevelCount <= 2 && race.raceInfo2.wakuLevelList.startsWith("A"))
					|| (race.raceInfo2.raceType.contains("準優勝"))
					|| (race.raceInfo2.fixedEntrance.equals("進入固定") )
					);
		} else if (betType.equals("2F") || betType.equals("2T")) {
			result =
				(
					(
					  (race.raceInfo2.aLevelCount <= 1 && race.raceInfo2.wakuLevelList.startsWith("A"))
					  || (race.raceInfo2.raceType.contains("準優勝"))
//					  || (race.raceInfo2.raceType.equals("優勝"))
					  || (race.raceInfo2.fixedEntrance.equals("進入固定") )
					)
//					&& (Integer.parseInt(race.calculatedInfo.startExhibitRank.substring(5, 6)) > 2)
					&& (Integer.parseInt(race.calculatedInfo.exhibitRank.substring(5, 6)) > 2)
					&& (Integer.parseInt(race.calculatedInfo.nationWiningRank.substring(0, 1)) > 2)
//					&& (Integer.parseInt(race.calculatedInfo.motor2Rank.substring(0, 1)) > 2)
					
				);
		} else if (betType.equals("3F")) {
			result =
				(
					(
					  (race.raceInfo2.aLevelCount <= 3 && 
					  	race.wakuList.get(0).level.startsWith("A")  && race.wakuList.get(1).level.startsWith("A")
					  	)
					  || (race.raceInfo2.raceType.contains("準優勝"))
					  || (race.raceInfo2.raceType.equals("優勝"))
					  || (race.raceInfo2.fixedEntrance.equals("進入固定") )
					)
					&& (
//					 (Integer.parseInt(race.calculatedInfo.startExhibitRank.substring(0, 1)) < 4)
					 (Integer.parseInt(race.calculatedInfo.exhibitRank.substring(5, 6)) > 4)
					 && (Integer.parseInt(race.calculatedInfo.nationWiningRank.substring(0, 1)) > 4)
//					&& (Integer.parseInt(race.calculatedInfo.motor2Rank.substring(0, 1)) > 4)
					)
				);
		}
		
		return result;
	}
	public static void main(String[] args) {
		System.out.println("123456".substring(5, 6));
	}
}

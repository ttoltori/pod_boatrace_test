2F
마틴 없음

2014부터하면 최종 흑자난다.
びわこで３，４枠にかけるロジック。
좀 더 다듬어 보자.

아래의 로직으로도 흑자이다.
		if (
				( waku2.motor2WiningRate > 30 )
				//&& ( waku2.nationWiningRate > 5 )
				 && ( waku3.nationWiningRate > 6 && waku4.nationWiningRate > 6)
				//&& (race.setu.timezone.equals("N"))
			) {
			race.popularItemList.add(new PopularItem(null, 0, 0));
		}

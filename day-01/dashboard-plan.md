# Dashboard 계획

## 1. Dashboard 사용자와 목적
- Dashboard를 볼 사용자: OTT 서비스의 검색/추천 기획 담당자, 콘텐츠 운영팀
- 이 사용자가 확인하려는 상황: 사용자들이 무엇을 검색하고 있는지, 검색이 실패(결과 없음)하는 경우가 얼마나 되는지, 검색 성능(응답 속도)에 문제가 없는지
- Dashboard를 본 뒤 할 다음 행동: 검색 결과가 없는 인기 키워드에 대해 콘텐츠 확보/제휴 검토, 검색 응답이 느린 구간 파악 후 인프라 개선 요청, 인기 검색어 기반 추천 콘텐츠 큐레이션 조정

## 2. 분석 질문
Dashboard에 넣기 전에 먼저 aggregation 또는 ES|QL로 확인할 질문을 적습니다.
1. 최근 기간 동안 가장 많이 검색된 키워드(Top 10)는 무엇인가?
2. 검색 결과가 0건인(zero-result) 검색은 전체의 몇 %이며, 어떤 키워드에서 주로 발생하는가?
3. 디바이스별(모바일/PC/TV 등) 검색량과 평균 응답 시간에 차이가 있는가?
4. 시간대별(요일/시간) 검색량 추이는 어떤 패턴을 보이는가?

## 3. 차트 계획
Day 4 수업 완료 기준은 Lens 차트 4개입니다. 각 차트는 하나의 질문에 답해야 합니다.
| 번호 | Lens 시각화 | 답할 질문 | 사용할 field | 집계 또는 표시 방식 | 결과를 본 뒤의 판단·행동 |
|---:|---|---|---|---|---|
| 1 | Metric | 전체 검색 건수와 zero-result 비율은? | search_keyword, result_count | Records Count / Average (result_count=0 비율) | 목표 zero-result 비율(예: 5% 이하) 초과 시 콘텐츠 확보 우선순위 논의 |
| 2 | Bar | 가장 많이 검색된 키워드 Top 10은? | search_keyword.keyword | Top values (terms, size=10) | 상위 키워드 기반 홈 화면 추천/배너 우선 노출 검토 |
| 3 | Table | zero-result 키워드는 무엇이고 얼마나 자주 발생하는가? | search_keyword.keyword, result_count | Top values + Count (result_count=0 필터) | 신규 콘텐츠 수급 또는 유사어 매핑(동의어 사전) 추가 검토 |
| 4 | Line | 시간대별 검색량 추이는 어떻게 변하는가? | search_timestamp | Date histogram (일/시간 단위 Count) | 검색량 피크 시간대에 서버 스케일링 계획 수립 |
> 평가 최소 기준은 차트 2개 이상이지만, 수업에서는 차트 4개를 완성합니다.

## 4. Control과 시간 설정
- Options list 또는 range control에 사용할 field: device_type.keyword (Options list), 필요시 content_genre.keyword 추가
- 이 control로 함께 좁힐 차트: 2번(Top 키워드), 3번(zero-result 키워드), 4번(시간대별 추이)
- Data View 이름: ott-search-logs*
- 시간 field: 사용
- 시간 field를 사용한다면 field 이름과 기간: search_timestamp, 최근 7일

## 5. 제목과 배치 계획
- Dashboard 제목: OTT 검색 로그 모니터링 대시보드
- 상단에 둘 차트 또는 control: Metric(전체 검색 건수/zero-result 비율), Options list(디바이스 필터), 시간 range picker
- 가운데에 둘 차트: Top 검색어 Bar 차트, zero-result 키워드 Table
- 하단에 둘 차트: 시간대별 검색량 Line 차트

## 6. Day 4 완료 기록
- 실제로 만든 차트 수:
- Dashboard 화면 캡처: `evidence/dashboard.png`
- 선택 export: `kibana/dashboard.ndjson`
- 계획과 다르게 바꾼 점 및 이유:

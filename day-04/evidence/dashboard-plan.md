# Day 4 개인 Dashboard 설계

## 1. 사용자와 목적

- 내 주제: Elasticsearch로 OTT 콘텐츠 키워드 검색 서비스
- 이 Dashboard를 볼 사람: OTT 서비스 콘텐츠 운영 담당자
- Dashboard를 보고 결정하거나 행동할 것: 어떤 장르·평점대 콘텐츠가 많고 적은지 파악해 콘텐츠 확보/노출 우선순위를 검토
- 사용할 index / Data View: contents (문서 수 1000)

## 2. 데이터 준비 경로

- [x] A: 개인 데이터로 제작
- [ ] B: 공통 products로 제작하며 개인 데이터 보강 규칙 작성
- [ ] C: 공통 Dashboard를 완성하고 개인 청사진에 집중

선택 이유: contents index에 1000건이 이미 적재되어 있고 genre(keyword)·rating(float)·available(boolean) 등 분류·수치·상태 field가 모두 존재해 개인 데이터로 바로 제작 가능

## 3. 질문-데이터-차트 청사진

| 번호 | 분석 질문 | 필요한 field | 현재 존재? | mapping type | 계산·그룹 방식 | 차트 | filter/control | 확인 기준 |
|---|---|---|---|---|---|---|---|---|
| Q1 전체 규모 | 전체 콘텐츠는 몇 개인가? | (없음, Records) | O | - | Count of records | Metric | 없음 | 1000 |
| Q2 그룹 비교 | 장르별 콘텐츠 수는 어떤가? | genre | O | keyword | Top values + Count | Bar | genre Options list | SF 157 / 드라마 156 / 멜로 143 / 코미디 142 / 다큐멘터리 135 / 스릴러 135 / 액션 132 |
| Q3 분포/정확한 값 | 평점은 어느 구간에 많이 몰려 있는가? | rating | O | float | Create custom ranges(0.5 단위) + Count | Bar | 없음 | min 2.0 / max 5.0 / avg 3.54 |
| Q4 상태/시간 | 시청 가능한 콘텐츠 비율은 얼마인가? | available | O | boolean | Top values + Count | Donut | 없음 | true 690 / false 310 |

## 4. 데이터 부족 분석

- 현재 데이터로 답할 수 없는 질문: 콘텐츠가 언제 카탈로그에 등록/추가됐는지에 따른 시간 흐름(월별 등록 추이)
- 부족한 field: added_at(또는 released_at) 같은 날짜 field
- 필요한 mapping type: date
- 필요한 값의 범위·범주·비율: 최근 1~2년 내 임의 날짜로 균등 분포
- 날짜가 필요하다면 기간과 단위: 최근 24개월, 월 단위 집계
- 한 문서가 의미할 사건 또는 대상: 해당 콘텐츠가 서비스 카탈로그에 추가된 시점
- 생성 또는 수집 방법: generate-data.ps1 생성 규칙에 날짜 범위 내 랜덤 날짜 필드를 추가해 재생성
- 데이터 수가 충분하다고 판단할 기준: 24개월 각 구간에 최소 수십 건 이상 분포해 Line 차트에서 구간별 차이가 보일 것

## 5. 제작 순서

1. contents Data View 확인(index pattern: contents) 후 공통 products Dashboard를 Save as로 복제해 개인본 생성
2. Q1 전체 콘텐츠 수 Metric 패널 제작
3. Q2 장르별 콘텐츠 수 Bar, Q3 평점 구간별 분포 Bar, Q4 시청 가능 비율 Donut 순서로 제작
4. genre Options list Control 추가 후 전체 패널 연동 확인, 제목·배치 정리 후 저장

## 6. 완료 예상 화면

- Dashboard 제목: D4 개인 미션 - OTT 콘텐츠 검색 - 무카에
- 필수 패널 수: 4 (전체 콘텐츠 수 Metric, 장르별 Bar, 평점 구간 Bar, 시청 가능 비율 Donut)
- 사용할 control/filter: genre Options list Control
- 저장할 캡처 파일명: p06-contents-dashboard-full.png

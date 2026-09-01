

Day 02 data · MD
# Day 2 데이터 준비 결과
 
> 예시 문장을 복사하지 말고 자신의 실제 실행 결과를 작성합니다.
> 실행하지 않은 항목은 완료로 표시하지 않습니다.
 
## 1. Index와 문서
 
- Index 이름: contents
- 문서 한 건의 의미: 검색결과 리스팅에 나오는 OTT 콘텐츠(영화/시리즈) 1편
- 실제 색인 건수: 1000건
- Mapping의 `dynamic` 설정: 별도로 지정하지 않음 (index-create.json에 dynamic 필드를 명시하지 않아 ES 기본값 true 적용 — 필요 시 GET /contents/_mapping으로 재확인)
## 2. 최종 Field
 
| Field | Type | 검색에서 사용할 목적 |
|---|---|---|
| content_id | keyword | 문서 고유 식별·정확 조회 |
| title | text | 제목 키워드 검색(풀텍스트) |
| available | boolean | 시청 가능 여부로 필터링 |
| genre | keyword | 장르별 필터링·집계(테마별 보기) |
| running_time | integer | 러닝타임 범위 검색·정렬 |
| rating | float | 평점 기준 필터링·정렬 |
| cast | text | 배우 이름으로 검색 |
| director | text | 감독 이름으로 검색 |
 
## 3. 대량 데이터 생성·색인 결과
 
- 생성 건수: 1000건 (generate-data.ps1 실행)
- 로컬 검증 결과: LOCAL CHECK PASS — 1000 documents, unique IDs, target index and NDJSON verified (validate-data.ps1)
- Bulk 색인 결과: load-data.ps1 정상 완료 (에러 없음, Docker 컨테이너 경유 Bulk 전송 성공)
- ES 실제 `_count`: 1000
- 분류·숫자·boolean 분포 확인 결과:
  - genre: SF 157, 드라마 156, 멜로 143, 코미디 142, 다큐멘터리 135, 스릴러 135, 액션 132 (7개 장르에 고르게 분포)
  - available: true 690건, false 310건
  - running_time: min 70, max 180, avg 124.317
  - rating: min 2.0, max 5.0, avg 3.54
## 4. Day 3 연결
 
- 검색 질문 기준: `docs/data-model.md`의 사용자 질문 3개
  1. 드라마 장르 전체 보여줘
  2. 평점이 4.0 이상인 작품들을 평점 높은 순으로 정렬
  3. 시청 가능한 작품 중 러닝타임이 90분 이상 150분 이하, 짧은 순 정렬
## 5. 결과 파일 위치
 
- Mapping: `elasticsearch/index-create.json`
- 실행 요청: `elasticsearch/requests.http`, `pbl-data/requests/verify-data-template.http`
- 대표 문서: `docs/data-model.md` (대표 문서 3건)
- 데이터 생성 설정: `pbl-data/my-data-settings.ps1`
- 생성 표본: `pbl-data/generated/contents-sample-30.ndjson`
- 생성 요약: `pbl-data/generated/generation-summary.json`
## 6. Pipeline 적용 판단
 
- 적용 / 미적용 / 보류: _[본인 판단 기입 — 아직 결정 전이면 "보류"로 표시]_
- 판단 이유: _[예: 개인 pipeline 구현은 선택 사항이므로, 검증 완료 후 필요성을 보고 결정 등 실제 이유 기입]_
## 7. 미완료·오류
 
- 없음 또는 현재 상태: 개인 index(contents) mapping 생성, 1000건 데이터 생성·검증·Bulk 적재까지 완료
- 다음에 할 작업: Day 3 검색 질문 3가지 기준으로 검색 요청 작성·테스트
 

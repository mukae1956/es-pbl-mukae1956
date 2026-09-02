# es-pbl-mukae1956

## OTT 콘텐츠 키워드 검색

### 1. 프로젝트 소개
* 문제와 사용자: OTT에서 영화나 드라마를 키워드로 검색/OTT 검색을 편하게 사용하고 싶어하는 사용자들을 위함
* ES로 검색할 문서 1건: https://developer.themoviedb.org/docs/getting-started?utm_source=chatgpt.com
* 이 주제를 선택한 이유: _(초안, 본인 말로 다듬어주세요)_ 평소 여러 OTT 서비스를 오가며 콘텐츠를 찾을 때 제목이 정확히 기억나지 않거나 장르·배우 이름 정도만 아는 경우가 많았고, 이런 상황에서 키워드 검색이 얼마나 정확하게 원하는 콘텐츠를 찾아주는지 직접 설계·구현해보고 싶어서 선택함

### 2. 실행 순서
* Docker 환경 시작: `day-01/docker`에서 `preflight.ps1` → `pull-images.ps1` → `start.ps1` → `status.ps1` 순서로 실행해 ES·Kibana 컨테이너 기동
* index와 mapping 생성: `elasticsearch/index-create.json`에 정의한 mapping(content_id, title, available, genre, running_time, rating, cast, director)을 Kibana Dev Tools Console에서 `PUT /contents`로 실행해 생성
* 데이터 생성·Bulk 적재: `pbl-data` 폴더에서 `generator/generate-data.ps1` → `validate-data.ps1` → `load-data.ps1` 순서로 PowerShell 실행 (my-data-settings.ps1 규칙 기준 1000건 합성 데이터 생성 후 Docker 컨테이너 경유 Bulk 적재)
* 검색 요청 실행: `elasticsearch/requests.http`에 사용자 질문 3가지에 대응하는 검색 쿼리를 작성해 Kibana Console에서 실행
* Kibana Dashboard 확인: 장르 분포, 시청 가능 여부, 평점·러닝타임 통계를 시각화한 Dashboard를 Kibana에서 구성 후 확인 (Day 4 예정)

### 3. 데이터와 mapping
* 문서 수: 1000건 (합성 데이터, generate-data.ps1로 생성)
* 데이터 생성 규칙과 seed: `my-data-settings.ps1` 기준 — Seed=20260901, content_id(id, 5자리, prefix CT), genre(choice, 7개 장르 중 랜덤), title(template, `{{genre}} 작품 {{sequence}}`), available(boolean, true 70%), running_time(integer, 70~180분), rating(decimal, 2.0~5.0), director(choice, 감독 후보 6명), cast(tags, 배우 후보 10명 중 1~3명)
* 개인정보 미사용 확인: 실제 이용자 개인정보는 전혀 사용하지 않음. cast/director 필드의 이름은 학습·테스트 목적의 예시 텍스트로 임의 배정한 것이며, 실 서비스 데이터가 아닌 규칙 기반 합성 데이터임
* 핵심 필드와 타입 선택 이유:
  - content_id: keyword — 문서를 정확히 식별·조회하기 위함(분석 대상 아님)
  - title, cast, director: text — 제목·배우·감독 이름으로 풀텍스트(키워드) 검색이 되어야 하므로
  - genre: keyword — 장르별 필터링·집계(aggregation)에 정확한 매칭이 필요하므로
  - available: boolean — 시청 가능 여부로 단순 필터링하기 위함
  - running_time: integer, rating: float — 범위 검색과 정렬(오름/내림차순)에 사용하기 위한 숫자 타입

### 4. 검색·품질 테스트

| 검색 질문 | 기대 결과 | 실제 결과 | 판정 |
|---|---|---|---|
| 드라마 장르 전체 보여줘 | genre=드라마인 문서만 조회됨 | | |
| 평점이 4.0 이상인 작품들을 평점 높은 순으로 정렬 | rating>=4.0 문서만, rating 내림차순 정렬 | | |
| 시청 가능한 작품 중 러닝타임이 90분 이상 150분 이하, 낮은 순 정렬 | available=true & 90<=running_time<=150 문서만, running_time 오름차순 | | |

### 5. Dashboard
* Dashboard 사용자: 원하는 콘텐츠를 빠르게 찾으려는 일반 시청자, 콘텐츠 구성을 점검하려는 서비스 운영자
* 차트 1이 답하는 질문: 보유 콘텐츠가 장르별로 어떻게 분포되어 있는가
* 차트 2가 답하는 질문: 시청 가능한 콘텐츠 비율과 평점 분포는 어떤가
* control/filter 목적: 장르·시청 가능 여부·러닝타임 범위를 필터로 걸어, 원하는 조건의 콘텐츠만 좁혀서 탐색할 수 있게 함

### 6. AI Search 확장 판단
* 적용 여부와 근거: _(초안, 본인 말로 다듬어주세요)_ 보류 — 우선 기본 키워드(BM25) 검색으로 title/cast/director 대상 검색 품질을 먼저 확인하고, "비슷한 분위기의 작품 추천"처럼 키워드 매칭만으로 해결이 안 되는 요구가 실제로 확인되면 그때 벡터 검색(dense_vector/kNN) 적용을 검토할 예정

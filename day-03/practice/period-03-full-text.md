# 3교시 실습 — 전문 검색 확장

## (공통) 문제 1 — 제공 코드로 여러 field 검색

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "multi_match": {
      "query": "무선 이어폰",
      "fields": ["name", "description"]
    }
  }
}
```

### 결과 입력

- `hits.total.value`:505
- 상위 3개 ID·name:P-00241(SoundLab 프리미엄 무선 이어폰), P-00305(Auralis 실속형 무선 이어폰), P-00529(NeoTech 스마트 무선 이어폰)
- 각 문서가 name·description 중 어디에서 의도와 연결되는가:name과 의도가 연결됨
- 상위 3개 관련/보류/무관 판정:관련

## (공통) 문제 2 — field boost 직접 구현

문제 1과 같은 조건을 유지하되 `name` 일치를 `description`보다 3배 중요하게 보는 Search API를 작성하세요.

### API 전체 입력

```http
GET /products/_search
{
    "size": 5,
    "query": {
        "multi_match": {
            "query": "무선 이어폰",
            "fields": ["name^3", "description"]
        }
    }
}
```

### 비교 결과

- 변경 전 상위 3개 ID:P-00241(SoundLab 프리미엄 무선 이어폰), P-00305(Auralis 실속형 무선 이어폰), P-00529(NeoTech 스마트 무선 이어폰)
- 변경 후 상위 3개 ID:P-00241(SoundLab 프리미엄 무선 이어폰), P-00305(Auralis 실속형 무선 이어폰), P-00529(NeoTech 스마트 무선 이어폰)
- 순위가 달라진 문서와 이유:순위가 달라지지 않았음
- boost가 사용자 의도에 유리했는가:유리하지 않았던 거 같음

## (공통) 문제 3 — 구문 검색 직접 구현

`products` index의 `name`에서 `무선 이어폰`이라는 단어 순서와 인접성을 중요하게 검색하세요. `slop`은 0, 최대 5건으로 구현하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "match_phrase": {
      "name": {
        "query": "무선 이어폰",
        "slop": 0
      }
    }
  }
}
```

### 결과 입력

- `hits.total.value`:249
- 상위 문서 ID·name:P-00241(SoundLab 프리미엄 무선 이어폰)
- 문제 1보다 결과가 같거나 줄어든 이유: slope으로 인해 더 엄격하게 문서를 확인하므로 value값은 더 줄어들었음 하지만 상위 문서의 경우, 무선과 이어폰이 붙어있는 상품이 이미 많이 존재해서 결과가 계속해서 같게 나오는 거 같음
- 구문 의도에 맞지 않는 문서가 있는가: 없음!

## (개인) 문제 4 — 여러 text field 검색

자기 프로젝트에서 같은 사용자 검색어가 적용될 수 있는 text field 2개 이상을 선택해 전문 검색을 구현하세요.

### 역할·검증 기준

- 각 field의 서비스 역할을 설명합니다.
- 상위 3개 문서를 사람이 평가합니다.
- 한 field만 필요한 도메인이라면 `match`를 선택하고 그 이유를 적어도 됩니다.

### API와 결과 입력

```http
GET /contents/_search
{
  "size": 5,
  "query": {
    "multi_match": {
      "query": "이민호, 정해인",
      "fields": ["title", "cast", "director"]
    }
  }
}
```

- 사용자 질문·검색어: 이민호와 정해인이 같이 나온 작품 찾아줘
- 선택 field와 역할:title(질문의 출력값인 작품명), cast(질문의 조건값인 배우명), director(감독명도 배우들과 동명이인이거나 겹칠 가능성을 대비하여 포함)
- 상위 3개 판정:원하는 조건대로 제대로 나옴
- query 선택 근거:여러 필드를 한 번에 검사하는 multi_match 선택

## (개인) 문제 5 — boost 또는 phrase 가설 검증

자기 검색에서 field boost 또는 phrase 중 하나를 선택해 기본 요청과 비교하세요.

### 역할·검증 기준

- 같은 index·데이터·검색어·size를 유지합니다.
- 한 요소만 변경합니다.
- 결과가 바뀌지 않아도 실제 결과대로 기록합니다.

### API와 결과 입력

```http
GET /contents/_search
{
  "size": 5,
  "query": {
    "multi_match": {
      "query": "이민호, 정해인",
      "fields": ["title", "cast^3", "director"]
    }
  }
}

```

- 선택한 가설:cast를 boost하면 더 필터링 된 결과가 나올 것이라고 예상함
- 변경 전·후 상위 3개:CT-00033, CT-00040, CT-00211/CT-00033, CT-00040, CT-00211
- 개선/보류/악화 판정:보류 (결과값이 동일함)
- 판정 근거:

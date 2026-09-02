# 4교시 실습 — 정확 조건과 경계

## (공통) 문제 1 — 제공 코드로 세 filter 확인

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "전자기기" } },
        { "term": { "in_stock": true } },
        { "range": { "price": { "gte": 50000, "lte": 200000 } } }
      ]
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 380
- 확인한 문서 ID 3개:P-00025, P-00129, P-00185
- 각 문서의 category / in_stock / price:
  - 전자기기 / true / 59400
  - 전자기기 / true / 53800
  - 전자기기 / true / 161600
- 조건을 위반한 문서가 있는가: 없음

## (공통) 문제 2 — 경계 포함 범위 직접 구현

`products`에서 category가 `전자기기`이고 가격이 50,000원 이상 200,000원 이하인 상품을 검색하세요. 최대 10건을 반환하고 `product_id`, `name`, `category`, `price`만 표시하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": ["product_id", "name", "category", "price"],
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "전자기기" } },
        { "range": { "price": { "gte": 50000, "lte": 200000 } } }
      ]
    }
  }
}
```

### 결과 입력

- `hits.total.value`:440
- 최소·최대 price:53800 , 199300
- 50,000 또는 200,000 경계 문서 존재 여부와 ID:없음

## (공통) 문제 3 — 경계 제외 범위 직접 구현

문제 2에서 다른 조건은 모두 그대로 유지하고 가격 조건만 50,000원 초과 200,000원 미만으로 바꾸세요. 한 요소만 변경해야 합니다.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": ["product_id", "name", "category", "price"],
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "전자기기" } },
        { "range": { "price": { "gt": 50000, "lt": 200000 } } }
      ]
    }
  }
}
```

### 비교 결과

- 문제 2 total / 문제 3 total: 440 / 440 
- 빠진 경계 문서 ID: 없음
- 경계 문서가 없어 결과가 같다면 확인한 근거:

## (개인) 문제 4 — 자기 정확 조건 2개

자기 데이터에서 정확 조건으로 사용할 field 2개를 선택해 두 조건을 모두 만족하는 검색을 구현하세요.

### 역할·검증 기준

- keyword·boolean 등 실제 mapping type에 적합해야 합니다.
- 실행 전 포함 예상 문서 1개와 제외 예상 문서 1개를 정합니다.
- 실행 후 `_source`로 판정합니다.

### API와 결과 입력

```http
GET /contents/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [
        { "term": { "genre": "액션" } },
        { "range": { "running_time": { "gt": 100, "lt":150 } } }
      ]
    }
  }
}
```

- field·type·값 2개:
  - genre(keyword) = 액션
  - running_time(integer) = 100 초과 150 미만
- 기대 ID / 제외 ID:
  - 기대 ID : CT-00003(액션, running_time 105)
  - 제외 ID : CT-00001(코미디, running_time 97)
- 실제 결과와 판정: 앞에서 기대했던 ID인 CT-00003이 포함된 것을 확인하였음. 두 필터가 의도한대로 정확히 동작함 확인!

## (개인) 문제 5 — 자기 범위와 경계 실험

자기 데이터의 numeric 또는 date field를 선택해 포함 경계와 제외 경계 요청을 각각 구현하세요.

### 역할·검증 기준

- 실제 데이터의 최소·최대 또는 의미 있는 경계값을 먼저 확인합니다.
- `gte/lte`와 `gt/lt` 외 조건은 동일하게 유지합니다.
- 경계 문서가 없으면 fixture 설계 또는 부재 근거를 기록합니다.

### API와 결과 입력

```http
#포함 경계
GET /contents/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [
        { "term": { "genre": "멜로" } },
        { "range": { "running_time": { "gte": 100, "lte": 122 } } }
      ]
    }
  }
}
#제외 경계
GET /contents/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [
        { "term": { "genre": "멜로" } },
        { "range": { "running_time": { "gt": 100, "lt": 122 } } }
      ]
    }
  }
}
```

- field / type / 경계값: genre, running_time, 100~122
- 포함 요청 total / 제외 요청 total: 37/41
- 달라진 문서 ID: CT-00048(running_time = 122), CT-00100(running_time = 122)
- 경계 판정: 경계값 100~122 중 122는 실제로 존재하고 있는 값임을 확인함, 포함 및 제외 경계로 총 4개 차이난다는 사실을 확인할 수 있었음

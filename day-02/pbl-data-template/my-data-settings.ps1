# 메모장에서 '=' 오른쪽 값과 field 규칙만 자신의 주제에 맞게 바꿉니다.
# 이 파일은 생성기가 읽는 PowerShell 변수 설정입니다. 제공된 형식을 유지하고 값과 규칙만 수정합니다.

$IndexName = 'contents'
$DocumentCount = 1000
$Seed = 20260901
$IdPrefix = 'CT'
$IdField = 'content_id'
$SampleCount = 30

# choice와 tags 규칙이 참조하는 도메인별 후보 목록입니다.
$Vocabularies = [ordered]@{
  genres = @('드라마', '액션', '코미디', 'SF', '다큐멘터리', '멜로', '스릴러')
  directors = @('이상용', '김지운', '이창동', '봉준호', '박찬욱', '윤제균')
  actors = @('이민호', '유아인', '박서준', '한소희', '정해인', '김태리', '송강호', '전지현', '이병헌', '수지')
}

# 문서는 위에서 아래 순서로 만들어집니다.
# template는 앞에서 만든 field와 {{sequence}}을 사용할 수 있습니다.
$FieldRules = @(
  @{ Name = 'content_id'; Kind = 'id'; Digits = 5 }
  @{ Name = 'genre'; Kind = 'choice'; Source = 'genres' }
  @{ Name = 'title'; Kind = 'template'; Template = '{{genre}} 작품 {{sequence}}' }
  @{ Name = 'available'; Kind = 'boolean'; TrueRatio = 0.70 }
  @{ Name = 'running_time'; Kind = 'integer'; Min = 70; Max = 180 }
  @{ Name = 'rating'; Kind = 'decimal'; Min = 2.0; Max = 5.0; Digits = 1 }
  @{ Name = 'director'; Kind = 'choice'; Source = 'directors' }
  @{ Name = 'cast'; Kind = 'tags'; Source = 'actors'; MinItems = 1; MaxItems = 3; MissingRatio = 0.02 }
)

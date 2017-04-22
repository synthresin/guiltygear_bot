# 김길티

길티기어 한국 유저 텔레그램 모임의 플매방 관리 봇

```
김길티 추가 방번호 - 플매방번호 추가
김길티 삭제 방번호 - 플매방번호 삭제
김길티 목록 - 플매방 목록 보기
김길티 모두삭제 - 플매방번호 모두 삭제
```

### 로컬 개발 위한 베타 셋업 법

ngrok을 사용하여, 현재 로컬 웹 서버 주소를 ngrok 으로 포워딩

```
  $ ngrok http 3000
```

이를 통해 얻은 https 주소를 베타 봇의 웹훅 url 로 등록

```
require 'telegram/bot'

api = Telegram::Bot::Api.new(beta_token)
api.call('setWebhook', {
  url: local_webhook_url
})
```

# App Store 등록 정보 현지화 초안

> **초안입니다. ASC에는 아직 올리지 않았습니다.** 사용자 확인 뒤 코디네이터가 입력합니다. 대상 앱: AchaCharge(`com.arex.achaCharge`), 다음 버전 기능 기준.

## 근거와 운영 메모

- **데이터 근거** (ASC, 2023-09 ~ 2026-10): 최초 다운로드의 98%가 한국 밖에서 나옵니다. 다운로드의 90%가 App Store 검색 유입입니다. 그런데 등록 정보는 ko 하나뿐이라 다른 나라 스토어에서도 한국어 이름·설명이 보입니다. 노출 대비 전환율은 0.56%로 유틸리티 동종 앱 하위 25%입니다.
- **로케일 선택 이유**: 다운로드 상위 국가에 맞췄습니다. 미국 15%(en-US)에 이어 러시아(ru), 브라질(pt-BR), 우크라이나(ru로 갈음), 튀르키예(tr), 프랑스(fr-FR), 독일(de-DE), 사우디(en-US로 갈음, ar는 이번 범위 밖)입니다. 여기에 앱 UI 지원 언어(ko·en·ja·es·pt-BR·ru·tr·fr·de)와 맞추려고 ja와 es-MX를 넣었습니다.
- **운영 메모**: 이름·부제는 새 버전 제출 때만 바뀝니다(설명·키워드·프로모션 텍스트는 버전 제출 때 함께 바뀌고, 프로모션 텍스트만 심사 없이 수시로 바꿀 수 있습니다). 따라서 이 초안의 이름·부제는 다음 버전 제출에 맞춰 넣어야 합니다.
- **작성 규칙**: 가격·통화를 쓰지 않습니다(스토어가 현지 가격을 보여 줌). 구독 자동 갱신 고지와 개인정보 처리방침·이용약관 링크는 각 언어로 유지했습니다. 공식 지원 컨트롤러는 DualSense뿐이며, 다른 컨트롤러는 "배터리 정보를 제공하는 컨트롤러"로 조건을 붙였습니다. 키워드의 xbox·ps5는 검색어이며 설명에서 지원을 단정하지 않습니다. 키워드는 이름·부제에 이미 있는 단어를 뺐습니다.
- **글자 수 검증**: 이름·부제·프로모션·설명은 문자 수, 키워드는 `printf '%s' "<키워드>" | wc -c` 바이트 수입니다.
- **개인정보 처리방침 URL**: `https://dy-solution.kr/privacy.html#acha-charge` (현재 원문 그대로)

## en-US — 영어 (미국)

| 항목 | 값 | 수 |
|---|---|---|
| 이름 | Ah Charge! Controller Battery | 29/30자 |
| 부제 | DualSense battery alerts | 24/30자 |
| 키워드 | `gamepad,ps5,xbox,genshin,low,level,widget,tester,input,notification,remind,joystick,lock,screen` | 95/100바이트 |
| 프로모션 텍스트 | Check your controller's battery at a glance. Pro warns you before it runs out, even while you use other apps. Watch an ad for 3 hours of Pro, or subscribe to go ad-free. | 169/170자 |
| 설명 | 아래 | 1230/4000자 |

설명:

```text
Ever had your controller die mid-game?
Ah Charge! shows your controller's battery level so you can charge it before it's too late.

[Free]
◼ See your controller's battery % inside the app
◼ Button input tester
◼ Home Screen widget
◼ Lock Screen widget
◼ Connection guide screen

[Pro]  (subscription, or watch an ad for 3 hours of access)
◼ Get an alert when the battery drops below your threshold (20% by default), even while you use other apps
◼ Live Activity on the Lock Screen and Dynamic Island (iOS 16.1+)
◼ No ads

Officially supported controller: Sony DualSense. Other controllers that report battery information may also work, but support is not guaranteed.

Auto-renewable subscription
Payment will be charged to your Apple ID account at confirmation of purchase. The subscription renews automatically unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions in your App Store account settings after purchase.
Plans: weekly, monthly, yearly

◼ Privacy Policy: https://dy-solution.kr/privacy.html#acha-charge
◼ Terms of Use: https://dy-solution.kr/terms.html
```

## ja — 일본어

| 항목 | 값 | 수 |
|---|---|---|
| 이름 | 忘れないで！コントローラー電池 | 15/30자 |
| 부제 | DualSenseの電池を通知でお知らせ | 20/30자 |
| 키워드 | `ゲーム,ゲームパッド,PS5,Xbox,原神,ウィジェット,ボタン,テスト,ロック画面` | 99/100바이트 |
| 프로모션 텍스트 | コントローラーの電池残量がひと目でわかります。Proなら他のアプリを使用中でも、残量が少なくなると通知。広告を見て3時間Proを体験、または購読で広告なしに。 | 79/170자 |
| 설명 | 아래 | 646/4000자 |

설명:

```text
ゲーム中にコントローラーの電池が切れた経験はありませんか？
「忘れないで！」は電池残量を見やすく表示し、切れる前に充電できるようお手伝いします。

【無料】
◼ アプリ内でコントローラーの電池残量（％）を確認
◼ ボタン入力テスター
◼ ホーム画面ウィジェット
◼ ロック画面ウィジェット
◼ 接続ガイド画面

【Pro】（購読、または広告視聴で3時間利用可能）
◼ 他のアプリの使用中でも、電池残量が設定した基準値（初期値20％）以下になると通知
◼ ロック画面とDynamic IslandのLive Activity（iOS 16.1以降）
◼ 広告なし

公式対応コントローラー：Sony DualSense。電池情報を提供するその他のコントローラーでも利用できる場合がありますが、動作は保証されません。

自動更新サブスクリプション
購入の確認時に、お支払いはApple IDアカウントに請求されます。サブスクリプションは、現在の期間が終了する24時間前までに解約しない限り、自動的に更新されます。更新料金は、現在の期間が終了する24時間以内に請求されます。購入後は、App Storeのアカウント設定でサブスクリプションの管理や解約ができます。
プラン：週間・月間・年間

◼ プライバシーポリシー: https://dy-solution.kr/privacy.html#acha-charge
◼ 利用規約: https://dy-solution.kr/terms.html
```

## es-MX — 스페인어 (멕시코)

| 항목 | 값 | 수 |
|---|---|---|
| 이름 | Ah Charge! Batería de mando | 27/30자 |
| 부제 | Alertas de batería DualSense | 28/30자 |
| 키워드 | `control,gamepad,ps5,xbox,genshin,widget,probador,botones,carga,notificación,juegos,joystick,bloqueo` | 100/100바이트 |
| 프로모션 텍스트 | Mira la batería de tu mando de un vistazo. Pro te avisa antes de que se agote, incluso en otras apps. Mira un anuncio y obtén 3 horas de Pro, o suscríbete sin anuncios. | 168/170자 |
| 설명 | 아래 | 1328/4000자 |

설명:

```text
¿Te ha pasado que el mando se apaga en plena partida?
Ah Charge! te muestra el nivel de batería de tu mando para que lo cargues a tiempo.

[Gratis]
◼ Consulta el % de batería del mando dentro de la app
◼ Probador de botones
◼ Widget en la pantalla de inicio
◼ Widget en la pantalla de bloqueo
◼ Pantalla de guía de conexión

[Pro]  (suscripción, o mira un anuncio para obtener 3 horas de acceso)
◼ Recibe un aviso cuando la batería baje del nivel que elijas (20 % por defecto), incluso mientras usas otras apps
◼ Live Activity en la pantalla de bloqueo y en la Dynamic Island (iOS 16.1 o posterior)
◼ Sin anuncios

Mando con soporte oficial: Sony DualSense. Otros mandos que ofrezcan información de batería podrían funcionar, pero no se garantiza.

Suscripción con renovación automática
El pago se cargará a tu cuenta de Apple ID al confirmar la compra. La suscripción se renueva automáticamente a menos que se cancele al menos 24 horas antes de que termine el periodo actual. Se cobrará la renovación dentro de las 24 horas previas al fin del periodo actual. Puedes administrar y cancelar tus suscripciones en los ajustes de tu cuenta de App Store después de la compra.
Planes: semanal, mensual y anual

◼ Aviso de privacidad: https://dy-solution.kr/privacy.html#acha-charge
◼ Términos de uso: https://dy-solution.kr/terms.html
```

## pt-BR — 포르투갈어 (브라질)

| 항목 | 값 | 수 |
|---|---|---|
| 이름 | Ah Charge! Bateria do Controle | 30/30자 |
| 부제 | Alerta de bateria DualSense | 27/30자 |
| 키워드 | `gamepad,joystick,ps5,xbox,genshin,widget,teste,botões,carga,notificação,jogos,tela,bloqueio` | 94/100바이트 |
| 프로모션 텍스트 | Veja a bateria do controle num relance. No Pro, você é avisado antes de acabar, mesmo em outros apps. Assista a um anúncio e ganhe 3 horas de Pro, ou assine sem anúncios. | 170/170자 |
| 설명 | 아래 | 1264/4000자 |

설명:

```text
Já teve o controle descarregado no meio do jogo?
O Ah Charge! mostra o nível de bateria do seu controle para você carregar a tempo.

[Grátis]
◼ Veja a % de bateria do controle dentro do app
◼ Testador de botões
◼ Widget na tela de início
◼ Widget na tela de bloqueio
◼ Tela de guia de conexão

[Pro]  (assinatura, ou assista a um anúncio para ter 3 horas de acesso)
◼ Receba um aviso quando a bateria ficar abaixo do nível definido (20% por padrão), mesmo usando outros apps
◼ Live Activity na tela de bloqueio e na Dynamic Island (iOS 16.1 ou superior)
◼ Sem anúncios

Controle com suporte oficial: Sony DualSense. Outros controles que informem o nível de bateria podem funcionar, mas não há garantia.

Assinatura com renovação automática
O pagamento será cobrado na sua conta do Apple ID na confirmação da compra. A assinatura é renovada automaticamente, a menos que seja cancelada pelo menos 24 horas antes do fim do período atual. A renovação será cobrada nas 24 horas anteriores ao fim do período atual. Você pode gerenciar e cancelar suas assinaturas nos ajustes da conta da App Store após a compra.
Planos: semanal, mensal e anual

◼ Política de Privacidade: https://dy-solution.kr/privacy.html#acha-charge
◼ Termos de Uso: https://dy-solution.kr/terms.html
```

## ru — 러시아어

| 항목 | 값 | 수 |
|---|---|---|
| 이름 | Ah Charge! Заряд геймпада | 25/30자 |
| 부제 | Заряд DualSense в уведомлениях | 30/30자 |
| 키워드 | `джойстик,ps5,xbox,genshin,виджет,тест,кнопки,игры` | 77/100바이트 |
| 프로모션 텍스트 | Заряд геймпада виден сразу. В Pro предупреждение придёт, даже когда вы в другом приложении. Посмотрите рекламу — 3 часа Pro, или оформите подписку без рекламы. | 159/170자 |
| 설명 | 아래 | 1306/4000자 |

설명:

```text
Бывало, что геймпад разряжался прямо посреди игры?
Ah Charge! показывает уровень заряда геймпада, чтобы вы успели поставить его на зарядку.

[Бесплатно]
◼ Уровень заряда геймпада в процентах прямо в приложении
◼ Тестер нажатий кнопок
◼ Виджет на экране «Домой»
◼ Виджет на экране блокировки
◼ Экран с подсказками по подключению

[Pro]  (подписка или просмотр рекламы — 3 часа доступа)
◼ Уведомление, когда заряд опускается ниже заданного порога (по умолчанию 20%), даже если вы пользуетесь другим приложением
◼ Live Activity на экране блокировки и в Dynamic Island (iOS 16.1 и новее)
◼ Без рекламы

Официально поддерживается геймпад Sony DualSense. Другие геймпады, передающие данные о заряде, могут работать, но поддержка не гарантируется.

Подписка с автоматическим продлением
Оплата списывается с вашей учётной записи Apple ID при подтверждении покупки. Подписка продлевается автоматически, если не отменить её минимум за 24 часа до окончания текущего периода. Плата за продление списывается в течение 24 часов до окончания текущего периода. Управлять подписками и отменять их можно в настройках учётной записи App Store после покупки.
Варианты: неделя, месяц, год

◼ Политика конфиденциальности: https://dy-solution.kr/privacy.html#acha-charge
◼ Условия использования: https://dy-solution.kr/terms.html
```

## tr — 튀르키예어

| 항목 | 값 | 수 |
|---|---|---|
| 이름 | Ah Charge! Oyun Kolu Pili | 25/30자 |
| 부제 | DualSense pil uyarıları | 23/30자 |
| 키워드 | `gamepad,ps5,xbox,genshin,widget,şarj,bildirim,test,düğme,joystick,kontrolcü,batarya` | 87/100바이트 |
| 프로모션 텍스트 | Oyun kolunun pil durumunu tek bakışta gör. Pro ile başka uygulamadayken bile pil azalmadan uyarı al. Reklam izleyip 3 saat Pro dene ya da abone olup reklamsız kullan. | 166/170자 |
| 설명 | 아래 | 1220/4000자 |

설명:

```text
Oyunun ortasında kolunun pili bitti mi hiç?
Ah Charge!, oyun kolunun pil seviyesini gösterir; geç olmadan şarj edebilirsin.

[Ücretsiz]
◼ Uygulama içinde oyun kolunun pil yüzdesini görme
◼ Düğme giriş test aracı
◼ Ana ekran widget'ı
◼ Kilit ekranı widget'ı
◼ Bağlantı rehberi ekranı

[Pro]  (abonelik veya reklam izleyerek 3 saatlik erişim)
◼ Pil, belirlediğin eşiğin (varsayılan %20) altına düşünce, başka uygulamaları kullanırken bile bildirim
◼ Kilit ekranı ve Dynamic Island'da Live Activity (iOS 16.1 ve üzeri)
◼ Reklamsız kullanım

Resmi olarak desteklenen oyun kolu: Sony DualSense. Pil bilgisi sağlayan diğer oyun kolları çalışabilir, ancak destek garanti edilmez.

Otomatik yenilenen abonelik
Satın alma onaylandığında ödeme Apple ID hesabınızdan tahsil edilir. Abonelik, mevcut dönemin bitiminden en az 24 saat önce iptal edilmediği sürece otomatik olarak yenilenir. Yenileme ücreti, mevcut dönemin bitiminden önceki 24 saat içinde tahsil edilir. Satın aldıktan sonra aboneliklerinizi App Store hesap ayarlarından yönetebilir ve iptal edebilirsiniz.
Planlar: haftalık, aylık, yıllık

◼ Gizlilik Politikası: https://dy-solution.kr/privacy.html#acha-charge
◼ Kullanım Koşulları: https://dy-solution.kr/terms.html
```

## fr-FR — 프랑스어 (프랑스)

| 항목 | 값 | 수 |
|---|---|---|
| 이름 | Ah Charge! Batterie manette | 27/30자 |
| 부제 | Alertes pour DualSense | 22/30자 |
| 키워드 | `jeu,gamepad,ps5,xbox,genshin,widget,test,boutons,niveau,notification,joystick,écran,verrouillage` | 97/100바이트 |
| 프로모션 텍스트 | Voyez la batterie de votre manette d'un coup d'œil. Avec Pro, soyez alerté avant la panne, même dans une autre app. Une pub = 3 h de Pro, ou abonnez-vous sans pub. | 163/170자 |
| 설명 | 아래 | 1395/4000자 |

설명:

```text
Votre manette s'est déjà éteinte en pleine partie ?
Ah Charge! affiche le niveau de batterie de votre manette pour que vous puissiez la recharger à temps.

[Gratuit]
◼ Niveau de batterie de la manette en % dans l'app
◼ Testeur de boutons
◼ Widget de l'écran d'accueil
◼ Widget de l'écran verrouillé
◼ Écran d'aide à la connexion

[Pro]  (abonnement, ou regardez une publicité pour 3 heures d'accès)
◼ Alerte quand la batterie passe sous le seuil choisi (20 % par défaut), même pendant que vous utilisez d'autres apps
◼ Live Activity sur l'écran verrouillé et dans la Dynamic Island (iOS 16.1 ou ultérieur)
◼ Aucune publicité

Manette officiellement prise en charge : Sony DualSense. D'autres manettes fournissant l'état de la batterie peuvent fonctionner, sans garantie.

Abonnement à renouvellement automatique
Le paiement sera débité de votre compte Apple ID à la confirmation de l'achat. L'abonnement se renouvelle automatiquement, sauf s'il est annulé au moins 24 heures avant la fin de la période en cours. Le renouvellement sera facturé dans les 24 heures précédant la fin de la période en cours. Vous pouvez gérer et résilier vos abonnements dans les réglages de votre compte App Store après l'achat.
Formules : hebdomadaire, mensuelle, annuelle

◼ Politique de confidentialité: https://dy-solution.kr/privacy.html#acha-charge
◼ Conditions d'utilisation: https://dy-solution.kr/terms.html
```

## de-DE — 독일어

| 항목 | 값 | 수 |
|---|---|---|
| 이름 | Ah Charge! Controller-Akku | 26/30자 |
| 부제 | DualSense-Akku Warnungen | 24/30자 |
| 키워드 | `gamepad,ps5,xbox,genshin,widget,test,tasten,laden,benachrichtigung,spiele,joystick` | 82/100바이트 |
| 프로모션 텍스트 | Den Akkustand deines Controllers auf einen Blick. Pro warnt dich rechtzeitig, auch in anderen Apps. Werbung ansehen für 3 Std. Pro oder abonnieren und werbefrei nutzen. | 168/170자 |
| 설명 | 아래 | 1345/4000자 |

설명:

```text
Controller mitten im Spiel leer gewesen?
Ah Charge! zeigt dir den Akkustand deines Controllers, damit du ihn rechtzeitig laden kannst.

[Kostenlos]
◼ Akkustand des Controllers in % direkt in der App
◼ Tasten-Tester
◼ Home-Bildschirm-Widget
◼ Sperrbildschirm-Widget
◼ Verbindungsanleitung

[Pro]  (Abo, oder Werbung ansehen für 3 Stunden Zugang)
◼ Benachrichtigung, wenn der Akku unter deinen Schwellenwert fällt (standardmäßig 20 %), auch während du andere Apps nutzt
◼ Live Activity auf dem Sperrbildschirm und in der Dynamic Island (iOS 16.1 oder neuer)
◼ Keine Werbung

Offiziell unterstützter Controller: Sony DualSense. Andere Controller, die Akkuinformationen liefern, funktionieren möglicherweise, eine Garantie gibt es dafür nicht.

Automatisch verlängerndes Abonnement
Die Zahlung wird bei Kaufbestätigung deinem Apple-ID-Account belastet. Das Abonnement verlängert sich automatisch, sofern es nicht mindestens 24 Stunden vor Ende des aktuellen Zeitraums gekündigt wird. Die Verlängerung wird innerhalb von 24 Stunden vor Ende des aktuellen Zeitraums berechnet. Nach dem Kauf kannst du deine Abos in den Account-Einstellungen des App Store verwalten und kündigen.
Optionen: wöchentlich, monatlich, jährlich

◼ Datenschutzerklärung: https://dy-solution.kr/privacy.html#acha-charge
◼ Nutzungsbedingungen: https://dy-solution.kr/terms.html
```

## ko — 한국어 (개정안)

| 항목 | 값 | 수 |
|---|---|---|
| 이름 | 아차 충전 ! 컨트롤러 배터리 | 16/30자 |
| 부제 | DualSense 배터리 알림 | 16/30자 |
| 키워드 | `game,gamepad,ps5,xbox,genshin,원신,위젯,버튼,테스터,게임,패드,잠금화면,듀얼센스` | 100/100바이트 |
| 프로모션 텍스트 | 컨트롤러 배터리를 한눈에 확인하세요. Pro는 다른 앱을 쓰는 중에도 배터리가 떨어지면 알려 드려요. 광고를 보면 3시간 동안 Pro 무료, 구독하면 광고 없이 이용해요. | 95/170자 |
| 설명 | 아래 | 664/4000자 |

설명:

```text
게임 중에 컨트롤러 배터리가 방전된 적 있나요?
아차 충전 !이 컨트롤러 배터리를 보여 줘서, 늦기 전에 충전할 수 있어요.

[무료 기능]
◼ 앱 안에서 컨트롤러 배터리 % 확인
◼ 버튼 입력 테스터
◼ 홈 화면 위젯
◼ 잠금 화면 위젯
◼ 연결 안내 화면

[Pro 기능]  (구독, 또는 광고 시청 시 3시간 이용권)
◼ 다른 앱을 쓰는 중에도 배터리가 정한 기준값(기본 20%) 이하로 떨어지면 알림
◼ 잠금 화면·Dynamic Island Live Activity (iOS 16.1 이상)
◼ 광고 없이 이용

공식 지원 컨트롤러: Sony DualSense. 배터리 정보를 제공하는 다른 컨트롤러는 동작할 수도 있지만, 지원을 보장하지는 않아요.

자동 갱신 구독
구매 확인 시 결제는 Apple ID 계정에 청구됩니다. 구독은 현재 기간이 종료되기 적어도 24시간 전에 취소하지 않으면 자동으로 갱신됩니다. 갱신 요금은 현재 기간이 종료되기 24시간 이내에 청구됩니다. 구독 후 App Store 계정 설정에서 구독을 관리하고 취소할 수 있습니다.
구독 기간: 1주일, 1개월, 1년

◼ 개인 정보 보호 정책: https://dy-solution.kr/privacy.html#acha-charge
◼ 이용 약관: https://dy-solution.kr/terms.html
```

## ko 개정 요약 (현재 원문 대비)

- 키워드 오타 `kensin` → `genshin`.
- 띄어쓰기·맞춤법 정리: `원할하게` → `원활하게` 등. (개정안은 문장을 새로 써서 해당 표현 자체가 없어졌습니다.)
- 가격 하드코딩(₩/$) 제거. 구독 기간만 표기.
- `[무료기능]`·`[유료기능]` 한 줄 붙임 문제를 줄바꿈으로 분리. 광고 시청 3시간 이용권, 잠금 화면 위젯, 연결 안내 화면 추가.
- 프로모션 텍스트는 현재 비어 있어(null) 새로 작성.

## 영어 스크린샷 문구 (다음 버전 화면 기준)

| # | 화면 | 헤드라인 | 글자 수 |
|---|---|---|---|
| 1 | 배터리 링 | Know your battery at a glance | 29 |
| 2 | 연결 안내 화면 | Connect in a few easy steps | 27 |
| 3 | 잠금 화면 위젯 | Battery on your Lock Screen | 27 |
| 4 | 저전력 알림 (Pro) | Get warned before it dies | 25 |
| 5 | 버튼 테스터 | Test every button instantly | 27 |

저전력 알림 장은 Pro 기능입니다. 헤드라인에 가격·수치·과장 표현을 쓰지 않았습니다.

---

*기준 브랜치: `feature/store-listing` · 최종 갱신: 2026-10-27*

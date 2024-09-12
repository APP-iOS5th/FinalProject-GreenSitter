# FinalProject-GreenSitter
앱스쿨 5기 떡잎마을방법대 최종 프로젝트

## 📌 프로젝트 소개
> 프로젝트 기간: 2024/07/22 ~ 2024/09/13

> 노션 링크: https://likelion.notion.site/2c740f9ccfe34ca7946635f9e08bdb1e

 식물 돌봄 서비스를 매칭해주는 앱.
 - 현재 위치를 기반으로 가까운 곳의 식물 돌봄이를 찾는 / 자원하는 게시물 및 지도 표기
 - 실시간 채팅 기능을 통해 사용자 간의 소통 및 약속 만들기 기능 제공
 - 돌봄 후기, 레벨을 통한 신뢰도 평가 가능


## 📌 팀원
| 이융의(팀장) | 박지혜(부팀장) | 김영훈 | 조아라 | 차지용 |
|:--:|:--:|:--:|:--:|:--:|
| 맵, 총괄 | 채팅, 알림 | 약속, 채팅| 게시물 | 로그인, 프로필 |
| [@iyungui](https://github.com/iyungui) | [@jihyeep](https://github.com/jihyeep) | [@kyhlsd](https://github.com/kyhlsd)| [@arachocho](https://github.com/arachocho) | [@wldyd2113](https://github.com/wldyd2113) |

## 📌 개발도구 및 기술스택
<img src="https://img.shields.io/badge/swift-F05138?style=for-the-badge&logo=swift&logoColor=white"><img src="https://img.shields.io/badge/xcode-147EFB?style=for-the-badge&logo=xcode&logoColor=white"><img src="https://img.shields.io/badge/figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white"><img src="https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white"><img src="https://img.shields.io/badge/Notion-000000?style=for-the-badge&logo=notion&logoColor=black"><img src="https://img.shields.io/badge/firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white">

#### 개발환경
- Swift 5.10
- Xcode 15.4
- iOS 17.0
#### 협업도구 
- Figma, Github, Notion
#### 기술스택
- iOS: UIKit
- Server: Firebase
- Software Architecture: MVVM
- SPM, FCM, Kingfisher


## 📌 기능
<table align="center">
  <tr>
    <th><code>게시물 리스트</code></th>
    <th><code>맵</code></th>
    <th><code>채팅</code></th>
    <th><code>약속</code></th>
    <th><code>프로필</code></th>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/5b0146f6-c781-4319-b836-031d4bc2b4e2" alt="게시물 리스트"></td>
    <td><img src="https://github.com/user-attachments/assets/7cc26cb1-5c22-4370-af8b-354dc03fc2d1" alt="맵"></td>
    <td><img src="https://github.com/user-attachments/assets/fa5be1ab-4dbc-448d-8688-62d214289030" alt="채팅"></td>
    <td><img src="https://github.com/user-attachments/assets/557b5a4f-e24b-4ac4-a371-b237a2802451" alt="약속"></td>
    <td><img src="https://github.com/user-attachments/assets/338758d7-eb6a-46ea-bac2-2f67c9034c41" alt="프로필"></td>
  </tr>
</table>
<br/>

#### 게시물 리스트
- 위치 기반 가까운 곳의 새싹 돌봄이를 찾는 / 자원하는 게시물 리스트 표기
- 사진, 거래 희망 위치 지원하며 수정 및 삭제 가능

#### 맵
- 새싹 돌봄이를 찾는 / 자원하는 사용자들을 지도로 표기하며 게시물과 연동
- 약속 만들기 전까지 500m 안 랜덤 표기로 위치 정보를 보호

#### 채팅
- 다른 사용자와의 실시간 채팅을 제공해 돌봄 서비스를 도움
- 사진, 카메라, 약속 정하기 기능을 제공하며 알림 설정 유무에 따라 푸시 알림 지원

#### 약속
- 원활한 서비스 이용을 위해 약속 시간, 장소를 정할 수 있는 기능을 제공
- 약속은 채팅방에 표기되며 알림 설정 유무에 따라 푸시 알림 지원

#### 프로필
- 프로필 이미지, 닉네임(중복 체크), 나의 위치 수정 가능
- 레벨 시스템, 돌봄 후기 등을 통한 신뢰도 확인


## 📌 회고
<details>
<summary>이융의 [@iyungui](https://github.com/iyungui) </summary>

#### Keep
- 데일리 회의로 팀원들의 상황을 파악해 소통하고 조율할 수 있었다.
- 맵 기능 구현 시 발생한 문제들을 신속히 해결해 일정에 맞춰 완료했다.
#### Problem
- 다른 팀원들의 작업을 도와주는 과정에서 작업 분배가 불균형 및 비효율적이라 느꼈다.
- 일부 기능에서 커뮤니케이션 부족으로 작업이 지연된 경우가 있었다.
#### Try
- 기능 별로 작업 범위와 예상 기간을 명확하게 나눠 중복 작업을 줄일 것.
- 서드파티 라이브러리(Tuist) 도입을 통해 효율적으로 프로젝트를 관리할 것.
- 회의 시간을 조금 줄이고, 비동기적으로 진행 상황을 체크해 시간 효율을 높일 것.

</details>

<details>
<summary>박지혜 [@jihyeep](https://github.com/jihyeep) </summary>

#### Keep
- 화면 기획 및 DB 설계 이후 개발을 진행해 수정되는 내용이 적어지고 소통이 원활했다.
- 처음 개발하는 기능이나 해결하기 어려운 오류에도 포기하지 않고 해결함으로 개발 역량을 키울 수 있었다.
#### Problem
- 다양한 디자인 패턴을 고려하지 못하고 MVVM으로 바로 진행해 올바르게 적용하지 못했다.
- 시간 내 완성을 목표로 하다보니 비효율적인 코드가 많아졌다.
#### Try
- 다양한 디자인 패턴을 적용해보고 앱에 적합한 패턴을 찾아 올바르게 적용할 것.
- 효율적인 비동기 작업 처리를 위한 프레임워크나 의존성 주입 등에 대한 리팩토링을 진행할 것.
</details>

<details>
<summary>김영훈 [@kyhlsd](https://github.com/kyhlsd) </summary>

#### Keep
- 화면 별 기능들을 미리 구상하고 역할을 나눠, 중복되거나 유사한 기능들을 서로 코드를 참고하며 개발 시간을 단축할 수 있었다.
- 외부 라이브러리 사용에 관해 공유가 빨라 전체적으로 적용해 성능 향상에 도움이 되었다.
#### Problem
- 기한이 다가올 수록 동작하는데만 급급한 코드를 작성하게 되어 비효율적인 코드가 늘어났다.
- 예상하지 못했던 오류들을 접해서 해결하긴 했지만 시간이 지연되어 다른 기능들에 충분한 시간을 투자하지 못했다.
#### Try
- 아키텍처 관련해 공부하고 적용해볼 것.
- 해결하지 못한 기능과 다른 해야할 기능들 사이의 균형을 잡아 적절하게 시간을 분배할 것.

</details>

<details>
<summary>조아라 [@arachocho](https://github.com/arachocho) </summary>

#### Keep
- 초기에 타임라인을 나누어 작업을 시작해 효율적인 개발 진행에 도움이 되었다.
- 원활히 소통하며 아이디어를 자유롭게 제안할 수 있었고, 머지를 서로 진행하며 관련 공부가 되었다.
#### Problem
- 해결되지 않는 문젤르 혼자 오랜 시간 해결하려다보니 시간이 지연되었다.
- 코드 작성 시 충분히 이해하지 못하고 빌드하는데 집중하여, 추후 수정 시 수정에 어려움을 겪음
#### Try
- 다른 팀원들의 코드도 이해하여 프로젝트 전체적인 흐름을 숙지할 것.
- 개인적인 트러블슈팅 내용도 적극 공유하여 함께 해결할 것.

</details>

<details>
<summary>차지용 [@wldyd2113](https://github.com/wldyd2113) </summary>

#### Keep
- 커밋 컨벤션을 미리 정해서 양식에 맞게 작성했다.
- 명세서를 작성하고 개발하니 편리함이 있었다.
#### Problem
- MVVM 패턴을 명확하게 적용하지 못했다.
- 중복된 코드들이 많아 복잡하고 비효율적이었다.
#### Try
- MVVM 명확하게 이해하고 적용할 것.
- 코드 재사용을 통해 효율적인 코드를 작성할 것.
</details>

# Models Overview

This project contains several key data models used to manage users, posts, reviews, chats, and contracts. Below is a breakdown of each model and its properties.

## User

| Property       | Type         | Description                         |
| -------------- | ------------ | ----------------------------------- |
| id             | String       | Unique identifier for the user      |
| enabled        | Bool         | User status (active/inactive)       |
| createDate     | Date         | User creation date                  |
| updateDate     | Date         | Last update date                    |
| profileImage   | String       | URL of user's profile image         |
| nickname       | String       | User's nickname                     |
| location       | Location     | User's location information         |
| platform       | String       | Platform user is on                 |
| levelPoint     | Level        | User's current level                |
| exp            | Int          | User's experience points            |
| aboutMe        | String       | User's bio                          |
| fcmToken       | String?      | Optional token for push notifications |

### Methods

- **updateExp(by: Int)**: Updates the user's experience points and adjusts the user's level accordingly.

---

## Post

| Property       | Type         | Description                         |
| -------------- | ------------ | ----------------------------------- |
| id             | String       | Unique identifier for the post      |
| enabled        | Bool         | Post status (active/inactive)       |
| createDate     | Date         | Post creation date                  |
| updateDate     | Date         | Last update date                    |
| userId         | String       | ID of the post creator              |
| postType       | PostType     | Type of the post                    |
| postTitle      | String       | Title of the post                   |
| postBody       | String       | Body content of the post            |
| location       | Location?    | Location associated with the post   |
| postStatus     | PostStatus   | Current status of the post          |

---

## Review

| Property       | Type         | Description                         |
| -------------- | ------------ | ----------------------------------- |
| id             | String       | Unique identifier for the review    |
| userId         | String       | ID of the user who created the review|
| postId         | String       | ID of the related post              |
| rating         | Rating       | Review rating (bad, average, good)  |
| reviewText     | String?      | Optional review text                |
| reviewImage    | String?      | Optional review image               |

---

## ChatRoom

| Property           | Type         | Description                         |
| ------------------ | ------------ | ----------------------------------- |
| id                 | String       | Unique identifier for the chat room |
| userId             | String       | ID of the user                      |
| postUserId         | String       | ID of the post owner                |
| messages           | [Message]    | Array of messages in the chat room  |
| postId             | String       | Related post ID                     |
| postTitle          | String       | Title of the post                   |
| postStatus         | PostStatus   | Current status of the post          |

---

## Message

| Property       | Type         | Description                         |
| -------------- | ------------ | ----------------------------------- |
| id             | String       | Unique identifier for the message   |
| senderUserId   | String       | ID of the message sender            |
| receiverUserId | String       | ID of the message receiver          |
| messageType    | MessageType  | Type of the message (text, image, etc.) |
| text           | String?      | Optional message text               |
| image          | [String]?    | Optional image URLs                 |
| plan           | Plan?        | Optional associated plan            |

---

## Plan

| Property           | Type         | Description                         |
| ------------------ | ------------ | ----------------------------------- |
| planId             | String       | Unique identifier for the plan      |
| planDate           | Date         | Date of the planned event           |
| planPlace          | Location?    | Optional location for the plan      |
| contract           | Contract?    | Optional associated contract        |
| isAccepted         | Bool         | Whether the plan has been accepted  |

---

## Contract

| Property           | Type         | Description                         |
| ------------------ | ------------ | ----------------------------------- |
| contractId         | String       | Unique identifier for the contract  |
| ownerId            | String       | ID of the plant owner               |
| sitterId           | String       | ID of the sitter                    |
| plantName          | String?      | Name of the plant                   |
| plantType          | String?      | Type of the plant                   |
| startCareDate      | Date         | Start date of care                  |
| endCareDate        | Date         | End date of care                    |

---

## Report

| Property       | Type         | Description                         |
| -------------- | ------------ | ----------------------------------- |
| reporterId     | String       | ID of the user reporting            |
| reportedId     | String       | ID of the user/post being reported  |
| reportType     | ReportType   | Type of the report (post or user)   |
| reportDate     | Date         | Date the report was filed           |
| reason         | String       | Reason for the report               |

---

## Block

| Property       | Type         | Description                         |
| -------------- | ------------ | ----------------------------------- |
| blockerId      | String       | ID of the user blocking             |
| blockedId      | String       | ID of the user/post being blocked   |
| blockType      | BlockType    | Type of the block (post or user)    |
| blockDate      | Date         | Date the block was made             |

---

## Enums

- **PostType**: Describes the type of post (`lookingForSitter`, `offeringToSitter`).
- **PostStatus**: Status of a post (`beforeTrade`, `inTrade`, `completedTrade`).
- **MessageType**: Describes the type of message (`text`, `image`, `plan`, `review`).
- **PlanType**: Type of the plan (`leavePlan`, `getBackPlan`).
- **Level**: User level progression from `rottenSeeds` to `fruit`.
- **Rating**: Review rating (`bad`, `average`, `good`).
- **ReportType**: Type of report (`post`, `user`).
- **BlockType**: Type of block (`post`, `user`).

## Location

| Property       | Type         | Description                         |
| -------------- | ------------ | ----------------------------------- |
| locationId     | String       | Unique identifier for the location  |
| latitude       | Double       | Latitude of the location            |
| longitude      | Double       | Longitude of the location           |
| placeName      | String       | Name of the place                   |
| address        | String       | Full address                        |


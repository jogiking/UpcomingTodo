# UpcomingTodo 

 <div align = center >
 <img width="200" align = .center alt="UpcomingTodoIconRounded" src="https://user-images.githubusercontent.com/38206212/113746893-ca70f180-9741-11eb-8c3d-c01e58e135f3.png"> 
</div>

> ### 해야 할 일을 쫓기듯이 관리  
남은 시간을 중심으로 보여주는 간단한 Todo 앱 입니다. 
iOS 14 의  기본 탑재 앱인`Reminder`와 비슷하게 만들었습니다.

- MVC ,  CoreData, Storyboard기반
- 앱스토어 출시  [`앱스토어 이동`](https://apps.apple.com/kr/app/upcomingtodo/id1559417645?app=itunes&ign-mpt=uo%3D4)
- 추가 설치 오픈소스 라이브러리 없음
-   Target - iOS 14.4,  언어 - 한국어, 영어
## 구조

![graph](https://user-images.githubusercontent.com/38206212/113746085-e32cd780-9740-11eb-8953-3e99d32883c5.JPG)

# MainPageView
<div>
<img width = "256" alt ="MainPageView" src="https://user-images.githubusercontent.com/38206212/113727440-16b33600-9730-11eb-913e-74ae046ac2c7.png">
<img width = "256" alt="MainPageView 편집모드" src ="https://user-images.githubusercontent.com/38206212/113727447-187cf980-9730-11eb-9b8a-b7cc54b68115.png">
<img width = "256" alt="MainPageView 편집모드" src ="https://user-images.githubusercontent.com/38206212/113727864-7f9aae00-9730-11eb-9268-6dbe73d83893.gif">
</div>

아래표는 MainPageView 기능입니다.

|번호             |기능 이름                 |설명                         |
|----------------|-------------------------------|-----------------------------|
|1				|`편집`			|`예정`에 보여줄 할 일과 `카탈로그`를 수정/삭제 할 수 있는 편집모드로 변경함|
|2				|`날짜(확대)`	|현재 날짜를 보여줌. 아래로 스크롤시 네비게이션 바 중앙으로 이동함|
|3				|`예정`			|선택한 마감 기한이 있는 할 일 상태를 보여줌. 마감 기한까지 남은 시간을 보여줌. 마감 기한이 있는 할 일이 없으면 `예정된 할 일 없음`이 표시됨. 마감 기한 설정을 최초 설정했다면 자동으로 메인화면에 표시됨. |
|4				|`진행 상황`|시작 시간부터 현재까지 지나간 시간을 마감 시간의 비율로 나타냄. 세부 항목도 마찬가지로 전체 세부 항목의 비율로 나타냄|
|5				|`전체`|전체 카테고리의 수를 보여줌|
|6				|`오늘`|마감 시간이 오늘인 할 일의 수를 보여줌|
|7				|`카탈로그`|최상위 분류의 목록을 보여줌|
|8				|`목록 추가`|새로운 카탈로그를 추가|
|9				|`완료(편집모드)`|편집모드를 종료|
|10				|`날짜(축소)`|편집모드일 때 날짜는 축소됨|
|11				|`할일 선택(편집)`|마감날짜가 있는 모든 할 일의 목록을 PickerView로 보여줌|
|12				|`카탈로그 삭제(편집모드)`|테이블뷰의 편집모드를 사용함|
|13				|`카탈로그 수정(편집모드)`|(i)를 누르면 카탈로그의 이름을 수정할 수 있음. 길게 눌러서 순서를 변경 할 수 있음|
|14				|`목록추가(편집모드)`|편집모드에서 새로운 카탈로그를 추가할 수 있음|






# TodoListView
<div>
<img width = "256" alt ="MainPageView" src="https://user-images.githubusercontent.com/38206212/113727605-3e0a0300-9730-11eb-86bb-28f5495fb336.jpeg">
<img width = "256" alt="MainPageView 편집모드" src ="https://user-images.githubusercontent.com/38206212/113727611-3fd3c680-9730-11eb-9fd5-5a93c600dd1c.jpeg">
</div>
<div>
<img width = "256" alt="MainPageView 편집모드" src ="https://user-images.githubusercontent.com/38206212/113727718-59750e00-9730-11eb-8ba7-1f110e6a1cdf.gif">
<img width = "256" alt="MainPageView 편집모드" src ="https://user-images.githubusercontent.com/38206212/113734279-2b92c800-9736-11eb-8d8b-9da20291ba9e.gif">
</div>

TodoListView는 iOS14 기본 탑재 앱인 `Reminder`와 유사한 인터페이스를 가지고 있습니다.

- 테이블 셀 축소/확장
- 편집 중 셀 악세사리 버튼(i) 누르면 DetailView로 이동
- 셀 드래그로 다른 셀의 하위 항목으로 이동(순서 저장), 순서 변경

# DetailView
<img width = "256" alt="MainPageView 편집모드" src ="https://user-images.githubusercontent.com/38206212/113738334-c50fa900-9739-11eb-8c31-d2c79b515c03.jpeg">

- 메모를 입력할 수 있습니다.
- 마감 시간을 설정할 수 있습니다(부모 셀인 경우)
- 마감 시간을 설정하면 MainPage, TodoList 화면에서 설정된 것을 볼 수 있습니다.


# 향후 수정사항
- MVVM  + Rx적용하기
- TodoListViewController에서 `편집 상태 유지 부분` 로직 검토
- 앱 기능 추가

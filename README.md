# Тестовое Doubletapp на позицию Flutter стажера.
## Задача
Трекер привычек
Необходимо создать приложения для трекинга привычек

Приложение должно состоять из двух экранов:

Экран со списком привычек

Экран добавления/редактирования привычки

Описание экранов

Экран со списком привычек

Каждый элемент списка должен иметь название, описание, приоритет, тип и
периодичность

На экране должен находиться TabBar для переключения между списками хороших и
плохих привычек

Переход на экран создания привычки осуществляется с помощью FAB (Floating Action
Button)

На экране должен быть Bottom sheet с фильтрацией по названию (т.е. поиск), а также
сортировкой по дате создания.

На элементе списка должна быть кнопка выполнения действия привычки

У плохих привычек, если их выполняли за указанный период менее часто, чем можно,
при нажатии выводить сообщение "Можете выполнить еще столько то раз , если
больше "Хватит это делать 

Для хороший привычки аналогично выводить "Стоит выполнить еще столько то раз
если выполнили меньше за указанный период, иначе "You are breathtaking!"
Экран добавления привычек

Необходимые поля
Название привычки

Описание
Приоритет, выбираемый с помощью Drop Down меню (Низкий, средний, высокий)

Тип привычки, выбираемый с помощью RadioButton (хорошая, плохая)

2 поля ввода для указания количества выполнения заданной привычки и с какой
периодичностью
После нажатия на кнопку сохранения необходимо возвращать пользователя на экран со
списком

Нажатие на элемент в списке открывает этот экран в режиме редактирования
State managment
При выполнение задания можете использовать знакомый вам подход
БД
Привычки должны сохраняться в локальную бд (moor, sqflite, hive)
Сеть
Локальную бд необходимо синхронизировать с сервером

Описание бэкенда: https://habits-internship.doubletapp.ai/swagger/index.html

Токен для общения сервером можно получить телеграм бота
@DoubletappAssignmentTokenBot с помощью команды /generate_server_token

## Использованные библиотеки
  hive_flutter: ^1.1.0  
  dio - для связи с сервером  
  connectivity_plus - для проверки соединения  
  flutter_bloc - для стейт менеджмента  
  get_it - для инъекции зависимостей  
  auto_route - для генерации путей  
  shimmer - для скелета списка привычек   
  fluttertoast - для отображения красивых встроенных уведомлений  
  talker_flutter - для логирования и удобства отладки  
  talker_dio_logger - для логирования запросов  
  talker_bloc_logger - для логирования изменений состояния  
  flutter_colorpicker - для выбора цвета привычки  
  mockito - для имитации зависимостей в тестах  
  hive_generator - для генерации моделей Hive  
  auto_route_generator - для генерации путей  
  
## Проблемы реализации
  Не хватило времени для изучения применения mockito в тестах при ограничениях поддержки null-safety в новых версиях Flutter.
## Установка
  Android debug apk: https://drive.google.com/file/d/1MFX-4nM0h4YyW62oFuFCLgKh4ZAJgleQ/view?usp=drive_link <br />
  Android release apk: https://drive.google.com/file/d/1k4cBi8gFplCIlyhawxgxVeDXrOk3AGQH/view?usp=drive_link

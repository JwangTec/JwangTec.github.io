---
title: 行为型设计模式-命令模式 Command
categories: 设计模式
tags:
  - 设计模式
  - 行为型设计模式
  - 命令模式
top: 90
abbrlink: 4030613938
date: 2021-12-20 09:48:52
password:
---



![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/mode/command.png)

<!--more-->

## 命令模式

命令模式（Command Pattern）是一种数据驱动的设计模式，它属于行为型模式。请求以命令的形式包裹在对象中，并传给调用对象。调用对象寻找可以处理该命令的合适的对象，并把该命令传给相应的对象，该对象执行命令。

### 什么是命令模式

命令模式是一个高内聚的模式，其定义为：将一个请求封装成一个对象，从而让你使用不同的请求把客户端参数化，对请 求排队或者记录请求日志，可以提供命令的撤销和恢复功能。

### UML

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/mode/command01.png)

### 使用场景


- 当需要先将一个函数登记上，然后再以后调用此函数时，就需要使用命令模式，其实这就是回调函数。

- 有时候需要向某些对象发送请求，但是并不知道请求的接收者是谁，也不知道被请求的操作是什么。此时希望用一种松耦合的方式来设计程序，使得请求发送者和请求接收者能够消除彼此之间的耦合关系

- Struts2中action中的调用过程中存在命令模式

- 数据库中的事务机制的底层实现

- 命令的撤销和恢复：增加相应的撤销和恢复命令的方法（比如数据库中的事务回滚）

## 角色划分

### 详细划分

- Command（抽象命令类）：抽象出命令对象，可以根据不同的命令类型。写出不同的实现类

- ConcreteCommand（具体命令类）：实现了抽象命令对象的具体实现

- Invoker（调用者/请求者）：请求的发送者，它通过命令对象来执行请求。一个调用者并不需要在设计时确定其接收者，因此它只与抽象命令来之间, 存在关联。在程序运行时，将调用命令对象的execute() ，间接调用接收者的相关操作。

- Receiver（接收者）：接收者执行与请求相关的操作，真正执行命令的对象。具体实现对请求的业务处理。未抽象前，实际执行操作内容的对象。

- Client（客户端）：在客户类中需要创建调用者对象，具体命令类对象，在创建具体命令对象时指定对应的接收者。发送者和接收者之间没有之间关系。都通过命令对象来调用。

### UML图简要划分

- Receiver接受者角色：该角色就是干活的角色，命令传递到这里是应该被执行的
- Command命令角色：需要执行的所有命令都在这里声明
- Invoker调用者角色：接收到命令，并执行命令

## 历程-万能遥控器例

近年来，智能家居越来越流行。躺在家中，只需要打开对应的 app，就可以随手控制家电开关。但随之而来一个问题，手机里的 app 实在是太多了，每一个家具公司都想要提供一个 app 给用户，以求增加用户粘性，推广他们的其他产品等。

站在用户的角度来看，有时我们只想打开一下电灯，却要先看到恼人的 “新式电灯上新” 的弹窗通知，让人烦不胜烦。如果能有一个万能遥控器将所有的智能家居开关综合起来，统一控制，一定会方便许多。

- 四个智能家居类结构

```java
//大门类
public class Door {
    public void openDoor() {
        System.out.println("门打开了");
    }

    public void closeDoor() {
        System.out.println("门关闭了");
    }
}

//电灯类
public class Light {
    public void lightOn() {
        System.out.println("打开了电灯");
    }

    public void lightOff() {
        System.out.println("关闭了电灯");
    }
}

//电视类
public class Tv {
    public void TurnOnTv() {
        System.out.println("电视打开了");
    }

    public void TurnOffTv() {
        System.out.println("电视关闭了");
    }
}
//音乐类
public class Music {
    public void play() {
        System.out.println("开始播放音乐");
    }

    public void stop() {
        System.out.println("停止播放音乐");
    }
}

```

### 万能遥控器1.0-功能单一

```java
// 初始化开关
Switch switchDoor = 省略绑定UI代码;
Switch switchLight = 省略绑定UI代码;
Switch switchTv = 省略绑定UI代码;
Switch switchMusic = 省略绑定UI代码;

// 初始化智能家居
Door door = new Door();
Light light = new Light();
Tv tv = new Tv();
Music music = new Music();

// 大门开关遥控
switchDoor.setOnCheckedChangeListener((view, isChecked) -> {
    if (isChecked) {
        door.openDoor();
    } else {
        door.closeDoor();
    }
});
// 电灯开关遥控
switchLight.setOnCheckedChangeListener((view, isChecked) -> {
    if (isChecked) {
        light.lightOn();
    } else {
        light.lightOff();
    }
});
// 电视开关遥控
switchTv.setOnCheckedChangeListener((view, isChecked) -> {
    if (isChecked) {
        tv.TurnOnTv();
    } else {
        tv.TurnOffTv();
    }
});
// 音乐开关遥控
switchMusic.setOnCheckedChangeListener((view, isChecked) -> {
    if (isChecked) {
        music.play();
    } else {
        music.stop();
    }
});
```

- 代码逻辑很简单，每一个开关状态改变时，调用对应的API实现开关按钮
- 缺点：功能单一

### 万能遥控器2.0-撤销功能

- 设计枚举类Operation，代表上次的每一步操作

```java
public enum Operation {
    DOOR_OPEN,
    DOOR_CLOSE,
    LIGHT_ON,
    LIGHT_OFF,
    TV_TURN_ON,
    TV_TURN_OFF,
    MUSIC_PLAY,
    MUSIC_STOP
}

```

- 客户端进行每一步操作都更新枚举类。撤销时进行回退

```java
public class Client {

    // 上一步的操作
    Operation lastOperation;
    
    @Test
    protected void test() {
        
        // 初始化开关和撤销按钮
        Switch switchDoor = 省略绑定UI代码;
        Switch switchLight = 省略绑定UI代码;
        Switch switchTv = 省略绑定UI代码;
        Switch switchMusic = 省略绑定UI代码;
        Button btnUndo = 省略绑定UI代码;

        // 初始化智能家居
        Door door = new Door();
        Light light = new Light();
        Tv tv = new Tv();
        Music music = new Music();

        // 大门开关遥控
        switchDoor.setOnCheckedChangeListener((view, isChecked) -> {
            if (isChecked) {
                lastOperation = Operation.DOOR_OPEN;
                door.openDoor();
            } else {
                lastOperation = Operation.DOOR_CLOSE;
                door.closeDoor();
            }
        });

        // 电灯开关遥控
        switchLight.setOnCheckedChangeListener((view, isChecked) -> {
            if (isChecked) {
                lastOperation = Operation.LIGHT_ON;
                light.lightOn();
            } else {
                lastOperation = Operation.LIGHT_OFF;
                light.lightOff();
            }
        });

        ... 电视、音乐类似

        btnUndo.setOnClickListener(view -> {
            if (lastOperation == null) return;
            // 撤销上一步
            switch (lastOperation) {
                case DOOR_OPEN:
                    door.closeDoor();
                    break;
                case DOOR_CLOSE:
                    door.openDoor();
                    break;
                case LIGHT_ON:
                    light.lightOff();
                    break;
                case LIGHT_OFF:
                    light.lightOn();
                    break;
                ... 电视、音乐类似
            }
        });
    }
}

```

- 栈结构：每次回退都会将最后一步Operation撤销，后进先出结构，实现回退多步操作

```java
public class Client {

    // 所有的操作
    Stack<Operation> operations = new Stack<>();

    @Test
    protected void test() {

        // 初始化开关和撤销按钮
        Switch switchDoor = 省略绑定UI代码;
        Switch switchLight = 省略绑定UI代码;
        Switch switchTv = 省略绑定UI代码;
        Switch switchMusic = 省略绑定UI代码;
        Button btnUndo = 省略绑定UI代码;

        // 初始化智能家居
        Door door = new Door();
        Light light = new Light();
        Tv tv = new Tv();
        Music music = new Music();

        // 大门开关遥控
        switchDoor.setOnCheckedChangeListener((view, isChecked) -> {
            if (isChecked) {
                operations.push(Operation.DOOR_OPEN);
                door.openDoor();
            } else {
                operations.push(Operation.DOOR_CLOSE);
                door.closeDoor();
            }
        });

        // 电灯开关遥控
        switchLight.setOnCheckedChangeListener((view, isChecked) -> {
            if (isChecked) {
                operations.push(Operation.LIGHT_ON);
                light.lightOn();
            } else {
                operations.push(Operation.LIGHT_OFF);
                light.lightOff();
            }
        });

        ...电视、音乐类似

        // 撤销按钮
        btnUndo.setOnClickListener(view -> {
            if (operations.isEmpty()) return;
            // 弹出栈顶的上一步操作
            Operation lastOperation = operations.pop();
            // 撤销上一步
            switch (lastOperation) {
                case DOOR_OPEN:
                    door.closeDoor();
                    break;
                case DOOR_CLOSE:
                    door.openDoor();
                    break;
                case LIGHT_ON:
                    light.lightOff();
                    break;
                case LIGHT_OFF:
                    light.lightOn();
                    break;
                ...电视、音乐类似
            }
        });
    }
}

```

- 实现原理：将每一步 Operation 记录到栈中，每次撤销时，弹出栈顶的 Operation，再使用 switch 语句判断，将其恢复
- 缺点：代码臃肿，违背单一原则和开闭原则

### 万能遥控器3.0-命令模式

- 命令接口ICommand：接口中只有一个 execute 方法，表示 “执行” 命令

```java
public interface ICommand {
    void execute();
}
```

- 开关命令，实现上面接口：将家居控制的代码转移到了命令类中，当命令执行时，调用对应家具的 API 实现开启或关闭。

```java
//开门
public class DoorOpenCommand implements ICommand {
    private Door door;

    public void setDoor(Door door) {
        this.door = door;
    }

    @Override
    public void execute() {
        door.openDoor();
    }
}
//关门
public class DoorCloseCommand implements ICommand {
    private Door door;

    public void setDoor(Door door) {
        this.door = door;
    }


    @Override
    public void execute() {
        door.closeDoor();
    }
}
//开灯
public class LightOnCommand implements ICommand {

    Light light;

    public void setLight(Light light) {
        this.light = light;
    }

    @Override
    public void execute() {
        light.lightOn();
    }
}
//关灯
public class LightOffCommand implements ICommand {

    Light light;

    public void setLight(Light light) {
        this.light = light;
    }

    @Override
    public void execute() {
        light.lightOff();
    }
}
```

- 客户端：遥控器只知道用户控制开关后，需要执行对应的命令，遥控器并不知道这个命令会执行什么内容，它只负责调用 execute 方法，达到了隐藏技术细节的目的。

```java
// 初始化命令
DoorOpenCommand doorOpenCommand = new DoorOpenCommand();
DoorCloseCommand doorCloseCommand = new DoorCloseCommand();
doorOpenCommand.setDoor(door);
doorCloseCommand.setDoor(door);
LightOnCommand lightOnCommand = new LightOnCommand();
LightOffCommand lightOffCommand = new LightOffCommand();
lightOnCommand.setLight(light);
lightOffCommand.setLight(light);
...电视、音乐类似

// 大门开关遥控
switchDoor.setOnCheckedChangeListener((view, isChecked) -> {
    if (isChecked) {
        doorOpenCommand.execute();
    } else {
        doorCloseCommand.execute();
    }
});
// 电灯开关遥控
switchLight.setOnCheckedChangeListener((view, isChecked) -> {
    if (isChecked) {
        lightOnCommand.execute();
    } else {
        lightOffCommand.execute();
    }
});
...电视、音乐类似

```

- 客户端优化：由于每个命令都被抽象成了同一个接口，我们可以将开关代码统一起来。

```java
public class Client {

    @Test
    protected void test() {
        ...初始化

        // 大门开关遥控
        switchDoor.setOnCheckedChangeListener((view, isChecked) -> {
            handleCommand(isChecked, doorOpenCommand, doorCloseCommand);
        });
        // 电灯开关遥控
        switchLight.setOnCheckedChangeListener((view, isChecked) -> {
            handleCommand(isChecked, lightOnCommand, lightOffCommand);
        });
        // 电视开关遥控
        switchTv.setOnCheckedChangeListener((view, isChecked) -> {
            handleCommand(isChecked, turnOnTvCommand, turnOffTvCommand);
        });
        // 音乐开关遥控
        switchMusic.setOnCheckedChangeListener((view, isChecked) -> {
            handleCommand(isChecked, musicPlayCommand, musicStopCommand);
        });
    }

    private void handleCommand(boolean isChecked, ICommand openCommand, ICommand closeCommand) { 
        if (isChecked) {
            openCommand.execute();
        } else {
            closeCommand.execute();
        }
    }
}
```

### 命令模式下实现撤销功能

- 同样使用一个栈结构，用于存储所有的命令，在每次执行命令前，将命令压入栈中。撤销时，弹出栈顶的命令，执行其 undo 方法即可。
- 命令模式使得客户端的职责更加简洁、清晰了，命令执行、撤销的代码都被隐藏到了命令类中。唯一的缺点是 —— 多了很多的命令类，因为我们必须针对每一个命令都设计一个命令类，容易导致类爆炸。

```java
//命令接口中，新增undo方法
public interface ICommand {
    
    void execute();

    void undo();
}
//开门命令中新增undo
public class DoorOpenCommand implements ICommand {
    private Door door;

    public void setDoor(Door door) {
        this.door = door;
    }

    @Override
    public void execute() {
        door.openDoor();
    }

    @Override
    public void undo() {
        door.closeDoor();
    }
}

//关门新增undo
public class DoorCloseCommand implements ICommand {
    private Door door;

    public void setDoor(Door door) {
        this.door = door;
    }

    @Override
    public void execute() {
        door.closeDoor();
    }

    @Override
    public void undo() {
        door.openDoor();
    }
}
//开灯命令undo
public class LightOnCommand implements ICommand {

    Light light;

    public void setLight(Light light) {
        this.light = light;
    }

    @Override
    public void execute() {
        light.lightOn();
    }

    @Override
    public void undo() {
        light.lightOff();
    }
}
//关灯
public class LightOffCommand implements ICommand {

    Light light;

    public void setLight(Light light) {
        this.light = light;
    }

    @Override
    public void execute() {
        light.lightOff();
    }

    @Override
    public void undo() {
        light.lightOn();
    }
}
//客户端

public class Client {

    // 所有的命令
    Stack<ICommand> commands = new Stack<>();

    @Test
    protected void test() {
        ...初始化

        // 大门开关遥控
        switchDoor.setOnCheckedChangeListener((view, isChecked) -> {
            handleCommand(isChecked, doorOpenCommand, doorCloseCommand);
        });
        // 电灯开关遥控
        switchLight.setOnCheckedChangeListener((view, isChecked) -> {
            handleCommand(isChecked, lightOnCommand, lightOffCommand);
        });
        // 电视开关遥控
        switchTv.setOnCheckedChangeListener((view, isChecked) -> {
            handleCommand(isChecked, turnOnTvCommand, turnOffTvCommand);
        });
        // 音乐开关遥控
        switchMusic.setOnCheckedChangeListener((view, isChecked) -> {
            handleCommand(isChecked, musicPlayCommand, musicStopCommand);
        });

        // 撤销按钮
        btnUndo.setOnClickListener(view -> {
            if (commands.isEmpty()) return;
            // 撤销上一个命令
            ICommand lastCommand = commands.pop();
            lastCommand.undo();
        });
    }

    private void handleCommand(boolean isChecked, ICommand openCommand, ICommand closeCommand) {
        if (isChecked) {
            commands.push(openCommand);
            openCommand.execute();
        } else {
            commands.push(closeCommand);
            closeCommand.execute();
        }
    }
}

```

### 宏命令

命令模式还有一个优点，那就是宏命令的使用，宏命令也就是组合多个命令的 “宏大的命令”。即`批量处理`



- 遥控器添加一个 “睡眠” 按钮，按下时可以一键关闭大门，关闭电灯，关闭电视、打开音乐

```java
public class MacroCommand implements ICommand {
    // 定义一组命令
    List<ICommand> commands;

    public MacroCommand(List<ICommand> commands) {
        this.commands = commands;
    }

    @Override
    public void execute() {
        // 宏命令执行时，每个命令依次执行
        for (int i = 0; i < commands.size(); i++) {
            commands.get(i).execute();
        }
    }

    @Override
    public void undo() {
        // 宏命令撤销时，每个命令依次撤销
        for (int i = 0; i < commands.size(); i++) {
            commands.get(i).undo();
        }
    }
}

```

- 有了宏命令，我们就可以任意组合多个命令，并且完全不会增加程序结构的复杂度。
- 将 doorCloseCommand, lightOffCommand, turnOffTvCommand, musicPlayCommand 三个命令组合到宏命令 sleepCommand 中，这个宏命令的使用方式和普通命令一模一样，因为它本身也是一个实现了 ICommand 接口的命令而已。

```java
//客户端
// 定义睡眠宏命令
MacroCommand sleepCommand = new MacroCommand(Arrays.asList(doorCloseCommand, lightOffCommand, turnOffTvCommand, musicPlayCommand));
// 睡眠按钮
btnSleep.setOnClickListener(view -> {
    // 将执行的命令保存到栈中，以便撤销
    commands.push(sleepCommand);
    // 执行睡眠命令
    sleepCommand.execute();
});
```

### 请求排队


- 要实现请求排队功能，只需创建一个命令队列，将每个需要执行的命令依次传入队列中，然后工作线程不断地从命令队列中取出队列头的命令，再执行命令即可。

- 事实上，安卓 app 的界面就是这么实现的。源码中使用了一个阻塞式死循环 Looper，不断地从 MessageQueue 中取出消息，交给 Handler 处理，用户的每一个操作也会通过 Handler 传递到 MessageQueue 中排队执行。


## 命令模式实现

### 详细角色划分实现

- Receiver类：知道如何实施与执行一个与请求相关的操作，任何类都可能作为一个接受者

```java
class Receiver
{
    public void Action()
    {
        Console.WriteLine("执行请求！");
    }
}
```

- Command类：用来声明执行操作的接口

```java
abstract class Command
{
    protected Receiver receiver;
    public Command(Receiver receiver)
    {
        this.receiver = receiver;
    }
    abstract public void Execute();
}
```

- ConcreteCommand类：将一个接受者对象绑定于一个动作，调用接受者相应的操作，以实现Execute。

```java
class ConcreteCommand : Command
{
    public ConcreteCommand(Receiver receiver) : base(receiver)
    {
    }

    public override void Execute()
    {
        receiver.Action();
    }
}
```

- Invoker类：要求该命令执行这个请求

```java
class Invoker
{
    private Command command;
    public void SetCommand(Command command)
    {
        this.command = command;
    }
    public void ExecuteCommand()
    {
        command.Execute();
    }
}
```

- 客户端代码

```java
static void Main(string[] args)
{
    Receiver r = new Receiver();
    Command c = new ConcreteCommand(r);
    Invoker i = new Invoker();

    i.SetCommand(c);
    i.ExecuteCommand();

    Console.Read();
}
```

### UML划分实现

- 首先定义一个命令的接收者，也就是到最后真正执行命令的那个人

```java
//接收者：真正执行命令的对象
public class Receiver {
    public void action(){
        System.out.println("命令执行了.......");
    }
}
```

- 然后定义抽象命令和抽象命令的具体实现，具体命令类中需要持有真正执行命令的那个对象。

```java
//抽象命令类：抽象的命令，可以根据不同类型的命令写出不同的实现
public interface Command {
    //调用命令
    void execute();
}
//具体命令类
class ConcreteCommand implements Command{
    private Receiver receiver;//持有真正执行命令对象的引用
    public ConcreteCommand(Receiver receiver) {
        super();
        this.receiver = receiver;
    }
    @Override
    public void execute() {
        //调用接收者执行命令的方法
        receiver.action();
    }
}
```

- 接下来就可以定义命令的发起者了，发起者需要持有一个命令对象。以便来发起命令。

```java
//请求者/调用者：发起执行命令请求的对象
public class Invoker {
    private Command command;//持有命令对象的引用
    public Invoker(Command command) {
        super();
        this.command = command;
    }
    public void call(){
        //请求者调用命令对象执行命令的那个execute方法
        command.execute();
    }
}
```

- 客户端测试：客户端

```java
public static void main(String[] args) {
    //通过请求者（invoker）调用命令对象（command），命令对象中调用了命令具体执行者（Receiver）
    Command command = new ConcreteCommand(new Receiver());
    Invoker invoker = new Invoker(command);
    invoker.call();
}
```

- 实现UML图

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/mode/command2.jpeg)


## 应用场景

- Struts2中action中的调用过程中存在命令模式

- 数据库中的事务机制的底层实现
- 命令的撤销和恢复：增加相应的撤销和恢复命令的方法（比如数据库中的事务回滚）
- 系统需要支持命令的撤销(Undo)操作和恢复(Redo)操作，也可以考虑使用命令模式
- 命令模式的实现过程通过调用者调用接受者执行命令，顺序：调用者→接受者→命令。

## 优缺点

### 优点



- 类间解耦：调用者角色与接收者角色之间没有任何依赖关系，调用者实现功能时只需调用Command 抽象类的execute方法就可以，不需要了解到底是哪个接收者执行。降低系统的耦合度。将 “行为请求者” 和 ”行为实现者“ 解耦。

- 可扩展性：Command的子类可以非常容易地扩展，而调用者Invoker和高层次的模块Client不产生严 重的代码耦合。增加或删除命令非常方便，并且不会影响其他类。
- 命令模式结合其他模式会更优秀：命令模式可以结合责任链模式，实现命令族解析任务；结合模板方法模式，则可以减少 Command子类的膨胀问题。
- 封装 “方法调用”，方便实现 Undo 和 Redo 操作。
- 灵活性强，可以实现宏命令。



### 缺点

- 会产生大量命令类。增加了系统的复杂性。






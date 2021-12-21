---
title: 行为型设计模式--责任链模式 Chain of responsibility
categories: 设计模式
tags:
  - 行为型模式
  - 责任链模式
top: 10
abbrlink: 1556789970
date: 2021-12-16 09:39:49
password:
---



![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/mode/chain%20of%20res.png)

<!--more-->

## 定义

- 为了避免请求发送者与多个请求处理者耦合在一起，于是将所有请求的处理者通过前一对象记住其下一个对象的引用而连成一条链；当有请求发生时，可将请求沿着这条链传递，直到有对象处理它为止。

- 在责任链模式中，客户只需要将请求发送到责任链上即可，无须关心请求的处理细节和请求的传递过程，请求会自动进行传递。所以责任链将请求的发送者和请求的处理者解耦了。

## 优缺点

责任链模式是一种对象行为型模式

### 优点

- **降低了对象之间的耦合度**。该模式使得一个对象无须知道到底是哪一个对象处理其请求以及链的结构，发送者和接收者也无须拥有对方的明确信息。
- **增强了系统的可扩展性**。可以根据需要增加新的请求处理类，满足开闭原则。
- **增强了给对象指派职责的灵活性**。当工作流程发生变化，可以动态地改变链内的成员或者调动它们的次序，也可动态地新增或者删除责任。
- **责任链简化了对象之间的连接**。每个对象只需保持一个指向其后继者的引用，不需保持其他所有处理者的引用，这避免了使用众多的 if 或者 if···else 语句。
- **责任分担**,每个类只需要处理自己该处理的工作，不该处理的传递给下一个对象完成，明确各类的责任范围，符合类的单一职责原则。

### 缺点

- **不能保证每个请求一定被处理**。由于一个请求没有明确的接收者，所以不能保证它一定会被处理，该请求可能一直传到链的末端都得不到处理。
- 对**比较长的职责链**，请求的处理可能涉及多个处理对象，**会增加过多对象**，而且会因为要等待链条处理完毕，会影响系统性能。
- 职责链建立的合理性要靠客户端来保证，**增加了客户端的复杂性**，可能会由于职责链的错误设置而导致系统出错，如可能会造成循环调用。

### 适用场景

- 有许多对象可以处理用户的请求，应用程序可以自动确定谁处理用户请求。
- 希望用户在不必明确指定接收者的情况下，向多个接收者提交一个请求，
- 程序希望动态定制可处理用户请求的对象集合。

## 涉及角色

### 抽象处理者（Handler）

定义一个处理请求的抽象类。可以定义一个方法，以设定和返回下一个节点的引用。

### 具体处理者（ConcreteHandler）

具体处理者在接收到请求之后可以选择将请求处理完毕，或者将请求传递给下一个节点。

### 客户（Client）

负责形成具体处理者的功能链，并传递初始的请求。


![UML](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/mode/chain01.png)

![执行流程图](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/mode/chain02.png)


## 示例1-员工请假申请

在生活中，经常遇到这样的问题。例如：在企业中，员工请假的问题。假设假期少于一天，可由组长决定；少于两天的，可由车间主任决定；大于两天的，由经理决定。组长、主任、经理构成了一条功能链。员工逐级向上进行申请，直到获得授权。再比如生产产品，需要经过多道工序。

### 简单实现

- 请求类，day为请假的天数。

```java
public class Request {
    public int day;

    public Request(int day) {
        this.day = day;
    }
}
```

- 抽象处理者类

```java
public abstract class Handler {
    private Handler next;

    public Handler getNext() {
        return next;
    }

    public void setNext(Handler next) {
        this.next = next;
    }

    public abstract boolean handle(Request req);
}
```

- 具体处理者类

```java
//组长
public class ZuZhang extends Handler{
    static int limit = 1;

    @Override
    public boolean handle(Request req) {
        if (req.day <= limit){
            System.out.println("ZuZhang agree the request!");
            return true;
        }
        return getNext().handle(req);
    }
}
//主任
public class ZhuRen extends Handler {
    static int limit = 2;

    @Override
    public boolean handle(Request req) {
        if (req.day <= limit){
            System.out.println("ZhuRen agree the request!");
            return true;
        }
        return getNext().handle(req);
    }
}
//经理
public class JingLi extends Handler{
    @Override
    public boolean handle(Request req) {
        System.out.println("JingLi agree the request!");
        return true;
    }
}
```

- 客户类，生成责任链的前后顺序关系。

```java
public class Chain {
    private Handler one = new ZuZhang();
    private Handler two = new ZhuRen();
    private Handler three = new JingLi();

    public void createChain(){
        one.setNext(two);
        two.setNext(three);
    }

    public void handle(Request req){
        one.handle(req);
    }
}

```

- 测试类

```java
public class Test {
    public static void main(String[] args) {
        Request req = new Request(2);
        Chain c = new Chain();
        c.createChain();
        c.handle(req);
    }
}
```

### 加入反射

对于示例1，Chain构建的责任链是固定的，需求发生变化，链中需要增加或删除节点。可采用**配置文件+反射**的方式

- 定义config.properties中的格式

`chain=ZuZhang,ZhuRen,JingLi`

- China2

```java
public class Chain2 {
    private Handler handler[];

    public void createChain() {
        try {
            String path = "路径\\config.properties";
            FileInputStream in = new FileInputStream(path);
            Properties p = new Properties();
            p.load(in);
            String s = p.getProperty("chain");
            String unit[] = s.split(",");
            int n = unit.length;
            handler = new Handler[n];
            for (int i = 0; i < n; i++) {
                handler[i] = (Handler) Class.forName(unit[i]).newInstance();
            }
            for (int i = 0; i < n - 1; i++) {
                handler[i].setNext(handler[i + 1]);
            }
            in.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void handle(Request req) {
        handler[0].handle(req);
    }
}

```

## 回调技术

回调就是类对象方法间相互调用的技术。例如：

```java
public class A {
    public void fA(){
        System.out.println("This is A::fA()");
        B obj = new B();
        obj.fB(this);
    }

    public void fA2(){
        System.out.println("This is A::fA2()");
    }

    public static void main(String[] args) {
        new A().fA();
    }
}

public class B {
    public void fB(A obj){
        System.out.println("This is B::fB()");
        obj.fA2();
    }
}

```

### 利用回调技术实现责任链模式

#### 示例

将英文字符串全部变为大写，同时去掉所有空格

- 定义抽象处理者接口Filter

```java
public interface Filter {
    void doFilter(Request req, Response rep,FilterChain fc);
}

```

- 请求类

```java
public class Request {
    String req;

    public Request(String req) {
        this.req = req;
    }
}

```

- 相应类

```java
public class Response {
    String rep;

    public Response(String rep) {
        this.rep = rep;
    }
}

```

- 具体处理类

```java
//小写变大写
public class UpperFilter implements Filter {
    @Override
    public void doFilter(Request req, Response rep, FilterChain fc) {
        String s = req.req;
        rep.rep = s.toUpperCase();
        fc.doFilter(req, rep, fc);
    }
}

//去除空格

public class BlankFilter implements Filter {
    @Override
    public void doFilter(Request req, Response rep, FilterChain fc) {
        String s = rep.rep;
        StringBuffer sbuf = new StringBuffer();
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            if (ch != ' ') {
                sbuf.append(ch);
            }
        }
        rep.rep = sbuf.toString();
        fc.doFilter(req, rep, fc);
    }
}

```

- 实现回调功能，生成过滤集合

```java
public class FilterChain implements Filter {
    ArrayList<Filter> ary = new ArrayList<>();
    int index = 0;

    void addFilter(Filter f) {
        ary.add(f);
    }

    @Override
    public void doFilter(Request req, Response rep, FilterChain fc) {
        if (index == ary.size()) {
            return;
        }
        Filter f = ary.get(index);
        index++;
        f.doFilter(req, rep, fc);
    }
}

```

- 测试

doFilter方法的实现是同步的，若请求处理时间很长，则程序无法执行其他功能

```java
public class Test {
    public static void main(String[] args) {
        Request req = new Request("i am a student");
        Response rep = new Response("");
        Filter upperFilter = new UpperFilter();
        Filter blankFilter = new BlankFilter();
        FilterChain fc = new FilterChain();
        fc.addFilter(upperFilter);
        fc.addFilter(blankFilter);
        fc.doFilter(req, rep, fc);
        System.out.println(rep.rep);
    }
}

```

### 异步调用-多线程实现

- FilterChain实现异步回调

```java
public class FilterChain {
    ArrayList<Filter> ary = new ArrayList<>();

    int index = 0;

    public void addFilter(Filter f){
        ary.add(f);
    }

    public void doFilter(Request req,Response rep,FilterChain fc){
        if (index == ary.size()){
            return;
        }
        Filter f = ary.get(index);
        index++;
        MyThread th = new MyThread(req,rep,f,fc);
        th.start();
    }
}

```

- 封装req、rep、f、fc

```java
public class MyThread extends Thread {
    Request req;
    Response rep;
    Filter f;
    FilterChain fc;

    public MyThread(Request req, Response rep, Filter f, FilterChain fc) {
        this.req = req;
        this.rep = rep;
        this.f = f;
        this.fc = fc;
    }

    @Override
    public void run() {
        f.doFilter(req, rep, fc);
    }
}

```

## 示例2-结合模版方法模式

### 模版方法

定义一个操作中算法的骨架，而将一些步骤延迟到子类中，模板方法使得子类可以不改变算法的结构即可重定义该算法的某些特定步骤。通俗点的理解就是 ：完成一件事情，有固定的数个步骤，但是每个步骤根据对象的不同，而实现细节不同；就可以在父类中定义一个完成该事情的总方法，按照完成事件需要的步骤去调用其每个步骤的实现方法。每个步骤的具体实现，由子类完成。

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/mode/chain3.png)


### 实现

- 责任链模版

```java
/**
 * 责任链模板
 */
public abstract class Handler {

    /**
     * 当前优惠政策等级
     */
    public final int rank;

    public Handler(int rank) {
        this.rank = rank;
    }

    private Handler nextHandler;

    public void setNextHandler(Handler nextHandler) {
        this.nextHandler = nextHandler;
    }

    public Handler getNextHandler() {
        return nextHandler;
    }

    /**
     * 用了模板方法设计模式（非常经典的一种设计模式，优雅），即预设一定流程，留下钩子函数，用户自定义实现
     *
     * @param customer 待处理客户
     */
    public void handle(Customer customer) {
        if (customer.getRank() >= rank) {
            handleHook(customer);
        }
        if (nextHandler != null) {
            nextHandler.handle(customer);
        }else {
            System.out.println("==================计算优惠结束======================");
        }
    }

    /**
     * 优惠政策具体实现
     *
     * @param customer 待处理客户
     */
    protected abstract void handleHook(Customer customer);
}
```

- 消费者


```java
public class Customer {

    /**
     * 消费等级
     */
    private int rank;

    /**
     * 姓名
     */
    private String name;

    /**
     * 消费额
     */
    private double consumption;

    public Customer(int rank, String name, double consumption) {
        this.rank = rank;
        this.name = name;
        this.consumption = consumption;
    }

    public int getRank() {
        return rank;
    }

    public double getConsumption() {
        return consumption;
    }

    public void setConsumption(double consumption) {
        this.consumption = consumption;
    }

    public void setRank(int rank) {
        this.rank = rank;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}

```

- 具体处理类

```java
/**
 * LV.1客户优惠处理
 */
public class FirstHandler extends Handler {

    /**
     * 当前优惠政策为LV.1客户
     */
    public FirstHandler() {
        super(1);
        //也可省去此处代码，在应用场景中自由组合
        setNextHandler(new TwiceHandler());
    }

    @Override
    protected void handleHook(Customer customer) {
        //模拟复杂逻辑处理
        System.out.println("==================开始计算优惠======================");
        customer.setConsumption(customer.getConsumption() * 0.7);
        System.out.println("你是LV." + customer.getRank() + "等客户"
                +customer.getName()+"，当前可享受7折"+"折扣后价格是"+customer.getConsumption());
    }
}


/**
 * LV.2客户优惠处理
 */
public class TwiceHandler extends Handler {

    /**
     * 当前优惠政策为LV.2客户
     */
    public TwiceHandler() {
        super(2);
    }

    @Override
    protected void handleHook(Customer customer) {
        //模拟复杂逻辑处理
        double consumption = customer.getConsumption() - Math.floor(customer.getConsumption() / 100) * 7;
        System.out.println("你是LV." + customer.getRank() + 
        	"等客户"+customer.getName()+"，可在7折优惠后满100-7元,折扣后价格是"+consumption);
    }
}

```

- 应用场景

```java
public class App {
    public static void main(String[] args) {
        Customer bob = new Customer(2, "bob", 1000);
        Customer tom = new Customer(1, "tom", 1000);

        new FirstHandler().handle(bob);
        new FirstHandler().handle(tom);
    }
}

```

## 责任链优化历程

普通的程序员可以解决中等难度的 bug，优秀程序员可以解决困难的 bug，而菜鸟程序员只能解决简单的 bug。为了将其量化，我们用一个数字来表示 bug 的难度，(0, 20] 表示简单，(20,50] 表示中等， (50,100] 表示困难，我们来模拟一个 bug 解决的流程

### 普通解决方法

- 新建一个bug类

```java
public class Bug {
    // bug 的难度值
    int value;

    public Bug(int value) {
        this.value = value;
    }
}

```

- 程序员类

```java
public class Programmer {
    // 程序员类型：菜鸟、普通、优秀
    public String type;

    public Programmer(String type) {
        this.type = type;
    }

    public void solve(Bug bug) {
        System.out.println(type + "程序员解决了一个难度为 " + bug.value + " 的 bug");
    }
}

```

- 客户端

```java

import org.junit.Test;

public class Client {
    @Test
    public void test() {
        Programmer newbie = new Programmer("菜鸟");
        Programmer normal = new Programmer("普通");
        Programmer good = new Programmer("优秀");

        Bug easy = new Bug(20);
        Bug middle = new Bug(50);
        Bug hard = new Bug(100);

        // 依次尝试解决 bug
        handleBug(newbie, easy);
        handleBug(normal, easy);
        handleBug(good, easy);

        handleBug(newbie, middle);
        handleBug(normal, middle);
        handleBug(good, middle);

        handleBug(newbie, hard);
        handleBug(normal, hard);
        handleBug(good, hard);
    }

    public void handleBug(Programmer programmer, Bug bug) {
        if (programmer.type.equals("菜鸟") && bug.value > 0 && bug.value <= 20) {
            programmer.solve(bug);
        } else if (programmer.type.equals("普通") && bug.value > 20 && bug.value <= 50) {
            programmer.solve(bug);
        } else if (programmer.type.equals("优秀") && bug.value > 50 && bug.value <= 100) {
            programmer.solve(bug);
        }
    }
}

```

- 代码逻辑很简单，我们让三种类型的程序员依次尝试解决 bug，如果 bug 难度在自己能解决的范围内，则自己处理此 bug。

- 输出没有问题，说明功能完美实现了，但在这个程序中，我们让每个程序员都尝试处理了每一个 bug，这也就相当于大家围着讨论每个 bug 该由谁解决，这无疑是非常低效的做法。那么我们要怎么才能优化呢？

### 指派一个负责任分发任务

实际上，许多公司会选择让项目经理来分派任务，项目经理会根据 bug 的难度指派给不同的人解决。

- 引入 ProjectManager 类

```java
public class ProjectManager {
    Programmer newbie = new Programmer("菜鸟");
    Programmer normal = new Programmer("普通");
    Programmer good = new Programmer("优秀");

    public void assignBug(Bug bug) {
        if (bug.value > 0 && bug.value <= 20) {
            System.out.println("项目经理将这个简单的 bug 分配给了菜鸟程序员");
            newbie.solve(bug);
        } else if (bug.value > 20 && bug.value <= 50) {
            System.out.println("项目经理将这个中等的 bug 分配给了普通程序员");
            normal.solve(bug);
        } else if (bug.value > 50 && bug.value <= 100) {
            System.out.println("项目经理将这个困难的 bug 分配给了优秀程序员");
            good.solve(bug);
        }
    }
}

```

- 修改客户端

```java
import org.junit.Test;

public class Client2 {
    @Test
    public void test() {
        ProjectManager manager = new ProjectManager();

        Bug easy = new Bug(20);
        Bug middle = new Bug(50);
        Bug hard = new Bug(100);

        manager.assignBug(easy);
        manager.assignBug(middle);
        manager.assignBug(hard);
    }
}

```

- 看起来很美好，除了项目经理在骂骂咧咧地反驳这个方案。

- 在这个经过修改的程序中，项目经理一个人承担了分配所有 bug 这个体力活。程序没有变得简洁，只是把复杂的逻辑从客户端转移到了项目经理类中。

- 而且项目经理类承担了过多的职责，如果以后新增一类程序员，必须改动项目经理类，将其处理 bug 的职责插入分支判断语句中，违反了单一职责原则和开闭原则。

### 简单责任链模式

在本例的场景中，每个程序员的责任都是“解决这个 bug”，当测试提出一个 bug 时，可以走这样一条责任链：

- 先交由菜鸟程序员之手，如果是简单的 bug，菜鸟程序员自己处理掉。如果这个 bug 对于菜鸟程序员来说太难了，交给普通程序员
- 如果是中等难度的 bug，普通程序员处理掉。如果他也解决不了，交给优秀程序员
- 优秀程序员处理掉困难的 bug

#### 代码优化

```java
import org.junit.Test;

public class Client3 {
    @Test
    public void test() throws Exception {
        Programmer newbie = new Programmer("菜鸟");
        Programmer normal = new Programmer("普通");
        Programmer good = new Programmer("优秀");

        Bug easy = new Bug(20);
        Bug middle = new Bug(50);
        Bug hard = new Bug(100);

        // 链式传递责任
        if (!handleBug(newbie, easy)) {
            if (!handleBug(normal, easy)) {
                if (!handleBug(good, easy)) {
                    throw new Exception("Kill the fake good programmer!");
                }
            }
        }

        if (!handleBug(newbie, middle)) {
            if (!handleBug(normal, middle)) {
                if (!handleBug(good, middle)) {
                    throw new Exception("Kill the fake good programmer!");
                }
            }
        }

        if (!handleBug(newbie, hard)) {
            if (!handleBug(normal, hard)) {
                if (!handleBug(good, hard)) {
                    throw new Exception("Kill the fake good programmer!");
                }
            }
        }
    }

    public boolean handleBug(Programmer programmer, Bug bug) {
        if (programmer.type.equals("菜鸟") && bug.value > 0 && bug.value <= 20) {
            programmer.solve(bug);
            return true;
        } else if (programmer.type.equals("普通") && bug.value > 20 && bug.value <= 50) {
            programmer.solve(bug);
            return true;
        } else if (programmer.type.equals("优秀") && bug.value > 50 && bug.value <= 100) {
            programmer.solve(bug);
            return true;
        }
        return false;
    }
}

```

- 三个嵌套的 if 条件句就组成了一条 菜鸟-> 普通 -> 优秀 的责任链。我们使 handleBug 方法返回一个 boolean 值，如果此 bug 被处理了，返回 true；否则返回 false，使得责任沿着 菜鸟-> 普通 -> 优秀这条链继续传递，这就是责任链模式的思路。

- 这段代码已经很好地体现了责任链模式的基本思想。我们平时使用的责任链模式只是在面向对象的基础上，将这段代码封装了一下。那么接下来我们就来对这段代码进行封装，将它变成规范的责任链模式的写法。

### 责任链模式

#### 程序员抽象类

```java
public abstract class Programmer {
    protected Programmer next;

    public void setNext(Programmer next) {
        this.next = next;
    }

    abstract void handle(Bug bug);
}

```
- next 对象表示如果自己解决不了，需要将责任传递给的下一个人；
- handle 方法表示自己处理此 bug 的逻辑，在这里判断是自己解决或者继续传递。

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/mode/chain04.png)


#### 具体处理者类

```java

//菜鸟程序员
public class NewbieProgrammer extends Programmer {

    @Override
    public void handle(Bug bug) {
        if (bug.value > 0 && bug.value <= 20) {
            solve(bug);
        } else if (next != null) {
            next.handle(bug);
        }
    }

    private void solve(Bug bug) {
        System.out.println("菜鸟程序员解决了一个难度为 " + bug.value + " 的 bug");
    }
}

//普通程序员
public class NormalProgrammer extends Programmer {

    @Override
    public void handle(Bug bug) {
        if (bug.value > 20 && bug.value <= 50) {
            solve(bug);
        } else if (next != null) {
            next.handle(bug);
        }
    }

    private void solve(Bug bug) {
        System.out.println("普通程序员解决了一个难度为 " + bug.value + " 的 bug");
    }
}

//优秀程序员
public class GoodProgrammer extends Programmer {

    @Override
    public void handle(Bug bug) {
        if (bug.value > 50 && bug.value <= 100) {
            solve(bug);
        } else if (next != null) {
            next.handle(bug);
        }
    }

    private void solve(Bug bug) {
        System.out.println("优秀程序员解决了一个难度为 " + bug.value + " 的 bug");
    }
}

```

#### 测试类

```java
import org.junit.Test;

public class Client4 {
    @Test
    public void test() {
        NewbieProgrammer newbie = new NewbieProgrammer();
        NormalProgrammer normal = new NormalProgrammer();
        GoodProgrammer good = new GoodProgrammer();

        Bug easy = new Bug(20);
        Bug middle = new Bug(50);
        Bug hard = new Bug(100);

        // 组成责任链
        newbie.setNext(normal);
        normal.setNext(good);

        // 从菜鸟程序员开始，沿着责任链传递
        newbie.handle(easy);
        newbie.handle(middle);
        newbie.handle(hard);
    }
}
```

- 在客户端中，我们通过 setNext() 方法将三个程序员组成了一条责任链，由菜鸟程序员接收所有的 bug，发现自己不能处理的 bug，就传递给普通程序员，普通程序员收到 bug 后，如果发现自己不能解决，则传递给优秀程序员，这就是规范的责任链模式的写法了。

- 责任链思想在生活中有很多应用，比如假期审批、加薪申请等，在员工提出申请后，从经理开始，由你的经理决定自己处理或是交由更上一层的经理处理。

- 再比如处理客户投诉时，从基层的客服人员开始，决定自己回应或是上报给领导，领导再判断是否继续上报。


















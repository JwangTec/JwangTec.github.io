---
title: Java虚拟机02--类加载器
categories: JVM
tags:
  - 类加载器
  - 类加载机制
  - 双亲委派
  - 自定义类加载器
top: 10
abbrlink: 2799334683
date: 2019-09-01 18:18:19
password:
---

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/JVM.png)


##  Java文件编译执行的过程

​	要想理解类加载器的话，务必要先清楚对于一个Java文件，它从编译到执行的整个过程。

<!--more-->

![image-20201020235156423](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20201020235156423.png)

- 类加载器：用于装载字节码文件(.class文件)
- 运行时数据区：用于分配存储空间
- 执行引擎：执行字节码文件或本地方法
- 垃圾回收器：用于对JVM中的垃圾内容进行回收

##  类加载器介绍

​	前面提到过，JVM只会运行二进制文件，而类加载器（ClassLoader）的主要作用就是将字节码文件加载到JVM中，从而让Java程序能够启动起来。现有的类加载器基本上都是java.lang.ClassLoader的子类，该类的只要职责就是用于将指定的类找到或生成对应的字节码文件，同时类加载器还会负责加载程序所需要的资源。该类中主要方法如下所示：

| 方法                                                 | 解释                                                         |
| ---------------------------------------------------- | ------------------------------------------------------------ |
| loadClass(String name)                               | 加载名称为 `name` 的类，并返回 `java.lang.Class` 类的实例    |
| findClass(String name)                               | 查找名称为 `name` 的类，并返回 `java.lang.Class` 类的实例    |
| findLoadedClass(String name)                         | 查找名称为 `name` 的已经被加载过的类，并返回 `java.lang.Class` 类的实例 |
| defineClass(String name, byte[] b, int off, int len) | 把字节数组 `b` 中的内容转换成 Java 类，并返回 `java.lang.Class` 类的实例 |
| resolveClass(Class<?> c)                             | 链接到指定类                                                 |

##   类加载机制

###   概述

​	类加载器是java.lang.ClassLoader类的子类对象或者C++代码编写的Bootstrap ClassLoader，它们的作用是加载字节码到JVM内存，得到Class类的对象。

​	类加载器根据各自加载范围的不同，划分为四种类加载器：

- **启动类加载器(BootStrap ClassLoader)：**

  该类并不继承ClassLoader类，其是由C++编写实现。用于加载**JAVA_HOME/jre/lib**目录下的类库。

- **扩展类加载器(ExtClassLoader)：**

  该类是ClassLoader的子类，主要加载**JAVA_HOME/jre/lib/ext**目录中的类库。

- **应用类加载器(AppClassLoader)：**

  该类是ClassLoader的子类，主要用于加载**classPath**下的类，也就是加载开发者自己编写的Java类。

- **自定义类加载器：**

  开发者自定义类继承ClassLoader，实现自定义类加载规则。

上述三种类加载器的层次结构如下如下：

![image-20201022112615215](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20201022112615215.png)

​	类加载器的体系并不是“继承”体系，而是**委派体系**，类加载器首先会到自己的parent中查找类或者资源，如果找不到才会到自己本地查找。类加载器的委托行为动机是为了避免相同的类被加载多次。

###   源码分析

加载器的类图如下:

![image-20201022105347634](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20201022105347634.png)

####  构造方法

```java
public Launcher() {
    Launcher.ExtClassLoader var1;
    try {
        //扩展类加载器
        var1 = Launcher.ExtClassLoader.getExtClassLoader();
    } catch (IOException var10) {
        throw new InternalError("Could not create extension class loader");
    }

    try {
        //将load属性，设为应用类加载器
        this.loader = Launcher.AppClassLoader.getAppClassLoader(var1);
    } catch (IOException var9) {
        throw new InternalError("Could not create application class loader");
    }

    Thread.currentThread().setContextClassLoader(this.loader);
    String var2 = System.getProperty("java.security.manager");
    if (var2 != null) {
        SecurityManager var3 = null;
        if (!"".equals(var2) && !"default".equals(var2)) {
            try {
                var3 = (SecurityManager)this.loader.loadClass(var2).newInstance();
            } catch (IllegalAccessException var5) {
            } catch (InstantiationException var6) {
            } catch (ClassNotFoundException var7) {
            } catch (ClassCastException var8) {
            }
        } else {
            var3 = new SecurityManager();
        }

        if (var3 == null) {
            throw new InternalError("Could not create SecurityManager: " + var2);
        }

        System.setSecurityManager(var3);
    }


```

####   ExtClassLoader类源码

```java
public static Launcher.ExtClassLoader getExtClassLoader() throws IOException {
    //调用私有方法getExtDirs(),用于加载指定目录下的文件信息
    final File[] var0 = getExtDirs();

    try {
        return (Launcher.ExtClassLoader)AccessController.doPrivileged(new PrivilegedExceptionAction<Launcher.ExtClassLoader>() {
            public Launcher.ExtClassLoader run() throws IOException {
                int var1 = var0.length;

                for(int var2 = 0; var2 < var1; ++var2) {
                    MetaIndex.registerDirectory(var0[var2]);
                }

                return new Launcher.ExtClassLoader(var0);
            }
        });
    } catch (PrivilegedActionException var2) {
        throw (IOException)var2.getException();
    }
}
```

```java
private static File[] getExtDirs() {
    //该方法内部会加载java.ext.dirs下的文件内容
    String var0 = System.getProperty("java.ext.dirs");
    File[] var1;
    if (var0 != null) {
        StringTokenizer var2 = new StringTokenizer(var0, File.pathSeparator);
        int var3 = var2.countTokens();
        var1 = new File[var3];

        for(int var4 = 0; var4 < var3; ++var4) {
            var1[var4] = new File(var2.nextToken());
        }
    } else {
        var1 = new File[0];
    }

    return var1;
}
```

####  AppClassLoader类源码

```java
public static ClassLoader getAppClassLoader(final ClassLoader var0) throws IOException {
    
    //该方法内部会加载java.class.path下的文件内容
    final String var1 = System.getProperty("java.class.path下的");
    final File[] var2 = var1 == null ? new File[0] : Launcher.getClassPath(var1);
    return (ClassLoader)AccessController.doPrivileged(new PrivilegedAction<Launcher.AppClassLoader>() {
        public Launcher.AppClassLoader run() {
            URL[] var1x = var1 == null ? new URL[0] : Launcher.pathToURLs(var2);
            return new Launcher.AppClassLoader(var1x, var0);
        }
    });
}
```

####   查看代码的类加载流程

```java
public class ClassLoaderTest {

    public static void main(String[] args) {

        String bootPath = System.getProperty("sun.boot.class.path");
        System.out.println("BootStrap ClassLoader加载的类的路径:------------------ ");
        System.out.println(bootPath.replaceAll(";",System.lineSeparator()));


        System.out.println("ExtClassLoader加载的类的路径:------------------");
        String extPath = System.getProperty("java.ext.dirs");
        System.out.println(extPath.replaceAll(";",System.lineSeparator()));


        System.out.println("AppClassLoader加载的类的路径:------------------");
        String appPath = System.getProperty("java.class.path");
        System.out.println(appPath.replaceAll(";",System.lineSeparator()));
    }
}
```

运行结果如下所示：

```
BootStrap ClassLoader加载的类的路径:------------------ 
C:/Program Files/Java/jdk1.8.0_101/jre/lib/resources.jar
C:/Program Files/Java/jdk1.8.0_101/jre/lib/rt.jar
C:/Program Files/Java/jdk1.8.0_101/jre/lib/sunrsasign.jar
C:/Program Files/Java/jdk1.8.0_101/jre/lib/jsse.jar
C:/Program Files/Java/jdk1.8.0_101/jre/lib/jce.jar
C:/Program Files/Java/jdk1.8.0_101/jre/lib/charsets.jar
C:/Program Files/Java/jdk1.8.0_101/jre/lib/jfr.jar
C:/Program Files/Java/jdk1.8.0_101/jre/classes

ExtClassLoader加载的类的路径:------------------
C:/Program Files/Java/jdk1.8.0_101/jre/lib/ext
C:/WINDOWS/Sun/Java/lib/ext

AppClassLoader加载的类的路径:------------------
C:/Program Files/Java/jdk1.8.0_101/jre/lib/charsets.jar
C:/Program Files/Java/jdk1.8.0_101/jre/lib/deploy.jar
C:/Program Files/Java/jdk1.8.0_101/jre/lib/ext/access-bridge-64.jar
```

###   类加载模型

​	在JVM中，对于类加载模型提供了三种，分别为全盘加载、双亲委派、缓存机制。

- **全盘加载：**

​	即当一个类加载器负责加载某个Class时，该Class所依赖和引用的其他Class也将由该类加载器负责载入，除非显示指定使用另外一个类加载器来载入。

- **双亲委派：**

​	即先让父类加载器试图加载该Class，只有在父类加载器无法加载该类时才尝试从自己的类路径中加载该类。简单来说就是，某个特定的类加载器在接到加载类的请求时，首先将加载任务委托给父加载器，依次递归，如果父加载器可以完成类加载任务，就成功返回；只有父加载器无法完成此加载任务时，才自己去加载。

- **缓存机制：**

​	会保证所有加载过的Class都会被缓存，当程序中需要使用某个Class时，类加载器先从缓存区中搜寻该Class，只有当缓存区中不存在该Class对象时，系统才会读取该类对应的二进制数据，并将其转换成Class对象，存入缓冲区中。从而可以理解为什么修改了Class后，必须重新启动JVM，程序所做的修改才会生效的原因。

##   双亲委派解析

###   概述

​	上述已经大致介绍了双亲委派，对于双亲委派具体的工作流程，如下图所示：

![image-20201022114925045](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20201022114925045.png)

###   源码分析

```java
public Class<?> loadClass(String name) throws ClassNotFoundException {
  //调用本类加载器的loadClass(String name, boolean resolve)方法
  return loadClass(name, false);
}
```

```java
protected Class<?> loadClass(String name, boolean resolve)
    throws ClassNotFoundException
{
    synchronized (getClassLoadingLock(name)) {
        // First, check if the class has already been loaded
         // 首先调用当前类加载器的findLoadedClass(name)，检查当前类加载器是否已加载过指定name的类
        Class c = findLoadedClass(name);
        
        //判断当前类加载器如果没有加载过
        if (c == null) {
            long t0 = System.nanoTime();
            try {
                
                //判断当前类加载器是否有父类加载器
                if (parent != null) {
                    //如果当前类加载器有父类加载器，则调用父类加载器的loadClass(name,false)方法
         			//父类加载器的loadClass方法，又会检查自己是否已经加载过
                    c = parent.loadClass(name, false);
                } else {
                    
                    //当前类加载器没有父类加载器，说明当前类加载器是BootStrapClassLoader
          			//则调用BootStrap ClassLoader的方法加载类
                    c = findBootstrapClassOrNull(name);
                }
            } catch (ClassNotFoundException e) {
                // ClassNotFoundException thrown if class not found
                // from the non-null parent class loader
            }

            if (c == null) {
                // If still not found, then invoke findClass in order
                // to find the class.
                // 如果调用父类的类加载器无法对类进行加载，则用自己的findClass(name)方法进行加载
                long t1 = System.nanoTime();
                c = findClass(name);

                // this is the defining class loader; record the stats
                sun.misc.PerfCounter.getParentDelegationTime().addTime(t1 - t0);
                sun.misc.PerfCounter.getFindClassTime().addElapsedTimeFrom(t1);
                sun.misc.PerfCounter.getFindClasses().increment();
            }
        }
        if (resolve) {
            resolveClass(c);
        }
        return c;
    }
}
```

###   JVM为什么采用双亲委派机制

1）通过双亲委派机制可以避免某一个类被重复加载，当父类已经加载后则无需重复加载，保证唯一性。

2）为了安全，保证类库API不会被修改

在工程中新建java.lang包，接着在该包下新建String类，并定义main函数

```java
public class String {

    public static void main(String[] args) {

        System.out.println("demo info");
    }
}
```

​	此时执行main函数，会出现异常，在类 java.lang.String 中找不到 main 方法

![image-20201022120956230](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20201022120956230.png)

​	出现该信息是因为由双亲委派的机制，java.lang.String的在启动类加载器(Bootstrap classLoader)得到加载，因为在核心jre库中有其相同名字的类文件，但该类中并没有main方法。这样就能防止恶意篡改核心API库。

##   自定义类加载器

​	对于自定义类加载器的实现也是很简单，只需要继承ClassLoader类，覆写findClass方法即可。

```java
//自定义类加载器，读取指定的类路径classPath下的class文件
public class MyClassLoader extends ClassLoader{

    private String classPath;

    public MyClassLoader(String classPath) {
        this.classPath = classPath;
    }

    @Override
    protected Class<?> findClass(String name) throws ClassNotFoundException {
        byte[] data = new byte[0];
        try {
            data = loadByte(name);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return defineClass(name, data, 0, data.length);
    }


    private byte[] loadByte(String name) throws Exception {
        name = name.replaceAll("//.", "/");
        FileInputStream fis = new FileInputStream(classPath + "/" + name + ".class");
        int len = fis.available();
        byte[] data = new byte[len];
        fis.read(data);
        fis.close();
        return data;
    }
}
```

```java
public class ClassLoaderTest {

    public static void main(String[] args) throws Exception {
        MyClassLoader classLoader = new MyClassLoader("D://workspace//course//java97//redisLock//src//main//java");
        Class clazz = classLoader.loadClass("com.itheima.demo.User");
        System.out.println(clazz.getClassLoader().getClass().getName());
    }
}
```

编写一个测试实体类，接着生成该类的字节码文件。

当存在.java文件时，根据双亲委派机制，显示当前类加载器为AppClassLoader，而当将.java文件删除时，则显示使用的是自定义的类加载器。


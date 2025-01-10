cdef extern from "stdio.h":
    int printf(const char *format, ...) nogil  # 明确声明 printf 为 C 函数

cdef extern from "pthread.h":
    int pthread_create(void* thread, void* attr, void* (*start_routine)(void*) noexcept nogil, void* arg)
    int pthread_join(void* thread, void* retval)

# 定义一个结构体来传递参数和返回值
cdef struct TaskArgs:
    int a
    int b
    int result  # 用于存储计算结果

cdef void* task(void* arg) noexcept nogil:
    # 将 void* 指针转换为 TaskArgs 结构体指针
    cdef TaskArgs* args = <TaskArgs*>arg

    # 进行计算
    args.result = args.a + args.b

    # 输出结果
    printf("计算结果: %d + %d = %d\n", args.a, args.b, args.result)

    # 返回结果指针
    return <void*>args

def run_parallel(int a, int b):
    cdef void* thread


    cdef TaskArgs args  # 定义参数结构体
    args.a = a
    args.b = b
    args.result = 0  # 初始化结果

    # 创建线程并传递参数
    # pthread_create 参数解释：
    #  1. &thread: 线程标识符的指针
    #  2. NULL: 线程属性，NULL表示使用默认属性
    #  3. <void* (*)(void*) noexcept nogil>task: 将task函数转换为符合pthread_create要求的函数指针类型
    #     - void* (*)(void*): 表示返回void*并接受void*参数的函数指针
    #     - noexcept: 表示该函数不会抛出异常
    #     - nogil: 表示该函数不需要Python的GIL（全局解释器锁）
    #  4. <void*>&args: 将args结构体的地址转换为void*指针传递给线程函数
    pthread_create(&thread, NULL, <void* (*)(void*) noexcept nogil>task, <void*>&args)
    pthread_join(thread, NULL)

    # 返回计算结果
    return args.result
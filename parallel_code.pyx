cdef extern from "stdio.h":
    int printf(const char *format, ...) nogil  # 明确声明 printf 为 C 函数

cdef extern from "pthread.h":
    int pthread_create(void* thread, void* attr, void* (*start_routine)(void*) noexcept nogil, void* arg)
    int pthread_join(void* thread, void* retval)

cdef extern from "unistd.h":
    void usleep(long usec) nogil

cdef void* task(void* arg) noexcept nogil:
    # 任务代码，不持有GIL且不会抛出异常
    # usleep(1000000)  # 睡眠1秒
    cdef int i
    cdef int result = 0
    for i in range(1000000):  # 执行100万次简单计算
        result += i * i  # 计算平方和
    printf("计算结果: %d\n", result)  # 打印计算结果

    # 这里返回<void*>是因为pthread线程函数的返回值类型必须是void*类型
    # 虽然我们计算的结果是int类型，但需要将其强制转换为void*指针类型返回
    # 这是因为pthread_create和pthread_join的接口设计要求线程函数返回void*类型
    # 在调用pthread_join时，可以通过将void*指针转换回int类型来获取实际的计算结果
    # 这种设计允许线程函数返回任意类型的数据，只需要将其转换为void*指针即可
    return <void*>result  # 将结果作为指针返回



def run_parallel():
    cdef void* thread
    cdef void* retval
    pthread_create(&thread, NULL, <void* (*)(void*) noexcept nogil>task, NULL)
    pthread_join(thread, &retval)
    cdef int result = <int>retval  # 将void*指针转换回int类型
    return result  # 返回计算结果

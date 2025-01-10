# 设置 Cython 语言级别
# cython: language_level=3

cdef extern from "stdio.h":
    int printf(const char *format, ...) nogil  # 明确声明 printf 为 C 函数

cdef extern from "stdlib.h":
    void* malloc(size_t size) nogil
    void free(void* ptr) nogil
    void* memcpy(void* dest, const void* src, size_t n) nogil

cdef extern from "pthread.h":
    ctypedef struct pthread_t:
        pass
    int pthread_create(pthread_t* thread, void* attr, void* (*start_routine)(void*) noexcept nogil, void* arg)
    int pthread_join(pthread_t thread, void* retval)

cdef extern from "unistd.h":
    void usleep(long usec) nogil

# 引入 libcurl 进行 HTTP 请求
cdef extern from "curl/curl.h":
    ctypedef void CURL
    ctypedef int CURLcode  # 修正 CURLcode 的定义
    CURL* curl_easy_init()
    CURLcode curl_easy_setopt(CURL* curl, int option, ...)
    CURLcode curl_easy_perform(CURL* curl)
    void curl_easy_cleanup(CURL* curl)
    int CURLOPT_URL
    int CURLOPT_WRITEDATA
    int CURLOPT_WRITEFUNCTION
    int CURLE_OK

# 定义回调函数来处理 HTTP 响应数据
cdef size_t write_callback(void* ptr, size_t size, size_t nmemb, void* userdata) nogil:
    cdef size_t real_size = size * nmemb
    cdef char* data = <char*>ptr
    cdef char** response = <char**>userdata

    # 分配内存并存储响应数据
    response[0] = <char*>malloc(real_size + 1)
    if response[0] == NULL:
        return 0  # 内存分配失败

    memcpy(response[0], data, real_size)
    response[0][real_size] = 0  # 添加字符串结束符
    return real_size

# 定义结构体来传递请求参数和结果
cdef struct RequestArgs:
    char* url
    char* response  # 用于存储 HTTP 响应数据

cdef void* task(void* arg) noexcept nogil:
    cdef RequestArgs* args = <RequestArgs*>arg
    cdef CURL* curl
    cdef CURLcode res

    # 初始化 CURL
    with gil:
        curl = curl_easy_init()
        if curl:
            # 设置 URL
            curl_easy_setopt(curl, CURLOPT_URL, args.url)

            # 设置回调函数
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, <void*>write_callback)
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, &args.response)

            # 执行请求
            res = curl_easy_perform(curl)
            if res != CURLE_OK:
                printf("HTTP 请求失败: %d\n".encode('utf-8'), res)

            # 清理 CURL
            curl_easy_cleanup(curl)
        else:
            printf("CURL 初始化失败\n".encode('utf-8'))

    return NULL

def run_parallel(url: str):
    cdef pthread_t thread
    cdef RequestArgs args

    # 将 Python 字符串转换为 C 字符串
    cdef bytes url_bytes = url.encode('utf-8')
    args.url = url_bytes
    args.response = NULL

    # 创建线程并执行 HTTP 请求
    pthread_create(&thread, NULL, <void* (*)(void*) noexcept nogil>task, <void*>&args)
    pthread_join(thread, NULL)

    # 将响应数据转换为 Python 字符串
    cdef str response_str
    if args.response != NULL:
        response_str = args.response.decode('utf-8')
        free(args.response)  # 释放内存
    else:
        response_str = ""

    return response_str
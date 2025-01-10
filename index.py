import parallel_code
from parallel_request import HttpClient

# 调用 Cython 中定义的函数
data = parallel_code.run_parallel(1, 2)


# # 创建客户端实例
client = HttpClient('https://www.baidu.com')

# GET请求
response = client.get('/api/data')
print(response)
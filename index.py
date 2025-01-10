import parallel_code

# 调用 Cython 中定义的函数
data =  parallel_code.run_parallel(1,2)
print(data)

# url = "https://www.baidu.com"
# response = run_request(url)
# print("HTTP 响应数据:", response)
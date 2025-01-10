import parallel_code

# 调用 Cython 中定义的函数
data =  parallel_code.run_parallel()
print(data)
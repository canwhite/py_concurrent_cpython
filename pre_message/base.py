import multiprocessing
from multiprocessing import Manager
import os 
from functools import partial #固定函数

def square_with_shared(x, shared_var):
    result = x * x
    # TODO, 验证这里是否需要get_lock
    # with shared_var.get_lock():  # 使用锁来保证线程安全
    shared_var.value += result  # 将结果累加到共享变量中
    return result

def main_with_shared():
    with Manager() as manager:
        shared_var = manager.Value('i', 0)  # 创建共享变量
        # 进程和cpu个数一致
        with multiprocessing.Pool(processes=os.cpu_count()) as pool:
            #将shared_var这个参数固定，只需要传入x数组就可以了
            func = partial(square_with_shared, shared_var=shared_var)
            results = pool.map(func, [1, 2, 3, 4, 5])
            
        print("计算结果:", results)
        print("共享变量总和:", shared_var.value)

if __name__ == "__main__":

    main_with_shared()
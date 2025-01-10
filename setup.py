from setuptools import setup
from Cython.Build import cythonize
from setuptools import Extension
import os

# 定义静态编译选项
extra_compile_args = ['-fPIC', '-static']
extra_link_args = ['-static']

# 如果是macOS系统，添加特定的编译选项
if os.uname().sysname == 'Darwin':
    extra_compile_args.extend(['-mmacosx-version-min=10.9'])
    extra_link_args.extend(['-mmacosx-version-min=10.9'])

# 定义扩展模块
extensions = [
    Extension(
        "parallel_code",
        sources=["parallel_code.pyx"],
        extra_compile_args=extra_compile_args,
        extra_link_args=extra_link_args,
        libraries=['pthread']  # 修正libraries参数格式
    )
]

# 配置setup
setup(
    name="ParallelCode",
    ext_modules=cythonize(extensions),
    include_dirs=['.'],
)
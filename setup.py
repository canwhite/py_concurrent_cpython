from setuptools import setup
from Cython.Build import cythonize
from setuptools import Extension
import os

# 定义静态编译选项
extra_compile_args = ['-fPIC', '-static']
extra_link_args = ['-static']

# 如果是 macOS 系统，添加特定的编译选项
if os.uname().sysname == 'Darwin':
    extra_compile_args.extend(['-mmacosx-version-min=10.9'])
    extra_link_args.extend(['-mmacosx-version-min=10.9'])

# 定义扩展模块
extensions = [
    Extension(
        "parallel_code",  # 模块名称
        sources=["parallel_code.pyx"],  # 只编译 parallel_code.pyx
        extra_compile_args=extra_compile_args,
        extra_link_args=extra_link_args,
        libraries=['curl', 'pthread']  # 确保 libcurl 和 pthread 正确链接
    ),
    Extension(
        "parallel_request",  # 模块名称
        sources=["parallel_request.pyx"],  # 只编译 parallel_request.pyx
        extra_compile_args=extra_compile_args,
        extra_link_args=extra_link_args,
        libraries=['curl', 'pthread']  # 确保 libcurl 和 pthread 正确链接
    )
]

# 配置 setup
setup(
    name="ParallelCode",
    ext_modules=cythonize(extensions),
    include_dirs=['.'],  # 包含当前目录
)
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

// 定义一个Object
typedef struct 
{
    int id;
    // char name[50]; //这样定义相当于提前预留50
    // 这里用char* 表示字符串
    char* name; 
} Object;

Object createObject(int id, char* name){
    //先声明再初始化的过程
    Object obj;
    obj.id = id;
    //先分配内存再给值
    obj.name = malloc(50*sizeof(char));
    strncpy(obj.name,name, 50);
    return obj;
}


//--FUNCTION，返回值类型和参数--
void test(int* a){
   printf("I am test,params - %d\n",*a); 
}


void normal_function(){
    // --- normal function 
    int b = 10;

    //声明一个指针
    //一般都是int* 声明，*a出现在解引用的时候
    int* a = NULL;
    //给指针引用
    a = &b;
    //将引用给到函数
    test(a);
}


//--STRING--
void string_use(){


    /******************************************
    1）使用字符串更好的方法是使用char数组，这样相当于提前分配了空间
    type name[size]
    
    2）如果你不是数组方式，可以自己去先给内存再给值

     * strcpy和strncpy，后者是内存安全的
    //a、先分配内存
    char* s1 = (char*)malloc(50*sizeof(char));
    //b、常量不能修改
    char* hello = "hello";
    //c、提供一个常量字符串，往分配好的内存空间copy，temp_name是空间头
    strcpy(s1, hello);

    以a、b、c 三个步骤 === char s1[50] = "hello";
    //后者没用malloc就不用释放了，这个数组名s1，相当于指针(地址)
    ******************************************/

    /** ----字符串拼接，strcat---- */
    char s1[50] = "hello";
    char* s2 = "World";

    strcat(s1,s2);


    /** ---数组名即地址，所以可以地址赋予--- */
    char* s3 = s1;
    //会从s3指针所指向的内存位置开始，连续读取字符，直到遇到\0结束
    //这个是c自动完成的，只有字符串会这样自动解引用
    printf("s3 : %s \n",s3);
    //那这样s3就不是直接new或者malloc出来的了，不需要释放了
    // free(s3);


    /** ---数组长度--- */
    char s4[] = "示例字符串";
    int len = strlen(s4);
    printf("s4 len : %d \n", len);

    char s5[] = "Hello";
    char s6[] = "World";
    

    /** ---比较两个字符串，等于返回0，小于负向-- */
    int result = strcmp(s5, s6);
    printf("cmp result : %d \n", result);


    /** ---char[]和char---
     * 注意这里是char，单引号
     */
    char s7[] = "Example string";
    char ch = 'r'; 
    /** --- strstr函数 ---
     * strstr用于在一个字符串中查找子字符串，找到返回位置指针 
     */
    char *res1 = strchr(s7, ch);


    /**
    在C语言中， 
    s7是一个指针，它指向一个字符数组（也就是字符串）的第一个字符。
    C语言会自动解引用这个指针
    而 *s1是解引用指针s1后得到的字符
    总结：指针一定程度上可以理解为地址和引用
    */
    printf("%s\n", res1);

    char s8[] = "Example string";
    char s9[] = "str"; //注意这里是str，双引号
    char *res2 = strstr(s8, s9);

}

/****************************
该方法主要是接收callback
 void：指示函数没有返回值。
 (*ptr)：意味着 ptr 是一个指针，指向一个函数。
 ()：表示这个被指向的函数接收的参数列表为空，即该函数不需要任何输入参数
***************************/


//先实现一个函数
void A(int a){
    printf("I am function A,params - %d\n",a);
}
void B(void (*ptr)(int)){
    (*ptr)(5);
}


int main(void){

    normal_function();

    string_use();

    // --- callback
    void (*ptr)(int) = &A;
    //传入的还是引用，然后内部实现的解引用
    B(ptr);
 
    // --- malloc、calloc、realloc


    Object (*createObj)(int,char*) = &createObject;


    int n = 5;
    //对于指针数组，当然字符串是char数组一样适用
    //1）先分配空间
    Object* objects_1 = (Object*)malloc(n * sizeof(Object));
    for (int i = 0; i < n; i++)
    {   
        //2）再初始化
        objects_1[i] = (*createObj)(i,"object_1_name");
        printf("%s \n",objects_1[i].name);
    }

    //calloc: contiguous allocation
    /** calloc和malloc的最大区别
    malloc只分配区间，
    calloc在分配区间的同时，所有位都初始化为0

    参数的主要区别在于
    将n*sizeof分成了两块儿
    */
   
    //1）先分配内存
    Object* objects_2 = (Object*)calloc(n,sizeof(Object));
    for (int i = 0; i < n; i++)
    {
        //2）再初始化
        objects_2[i] = (*createObj)(i,"object_2_name");
        printf("%s \n",objects_2[i].name);
    }
    
    //realloc: reallocate
    //使用realloc可以在原有的基础上扩大空间,用于实现动态数组
    //1）先分配内存
    objects_1 = (Object*)realloc(objects_1, 10*sizeof(Object));
    for (int i = 5;  i < 10; i++)
    {
        //往这个空间上值
        objects_1[i] = (*createObj)(i,"object_1_name");
        printf("%s \n",objects_1[i].name);
    }

    //释放堆内存
    //只要是分配了内存的，最后记得要清理
    for (int i = 0; i < 10; i++)
    {
        free(objects_1[i].name);
    }
    for (int i = 0; i < n; i++)
    {
        free(objects_2[i].name);
        
    }
    free(objects_1);
    free(objects_2);



    return 0 ; 
}

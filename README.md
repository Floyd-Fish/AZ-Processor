# AZ-Processor
很久以前就听说了这本书很有趣...一直想买，直到2020年才实现这个梦想:D     

![alt book](/img/1.jpg)

作为我学习这本书的记录，我会将写(抄)的代码上传到这个repo里...  
因为这本书最后做出来的CPU叫AZ-Processor，所以用了这个作为repo的title。  

作者在书上将代码归纳到一个表格中说明，在此列出:

## 模块层次

- chip_top              顶层模块
  - clk_gen                 时钟生成模块
    - x_s3e_dcm                 赛灵思 Digital Clock Manager
  - chip                SoC顶层模块
    - cpu                   CPU顶层模块
      - if_stage                IF阶段
        - bus_if                    总线接口
        - if_reg                    IF/ID流水线寄存器
      - id_stage                ID阶段
        - decoder                   指令解码
        - id_reg                    ID/EX流水线寄存器
      - ex_stage                EX阶段
        - alu                       算数运算单元
        - ex_reg                    EX/MEM流水线寄存器
      - mem_stage               MEM阶段
        - bus_if                    总线接口
        - mem_ctl                   内存访问控制单元
        - mem_reg                   MEM/WB流水线寄存器
      - ctrl                    CPU控制单元
      - gpr                     通用寄存器
      - spm                     SPM暂时存储器
        - x_s3e_dpram               赛灵思存储器宏 双端口RAM
    - rom                   ROM
      - x_s3e_sprom             赛灵思存储器宏 单端口ROM
    - timer                 定时器
    - uart                  UART顶层模块
      - uart_tx                 UART发送模块
      - uart_rx                 UART接收模块
      - uart_ctrl               UART控制模块
    - gpio                  GPIO
    - bus                   总线顶层模块
      - bus_addr_dec            地址解码器
      - bus_arbiter             总线仲裁器
      - bus_master_mux          总线主控多路复用器
      - bus_slave_mux           总线从属多路复用器

## 头文件一览  

| 文件名 | 说明 |
| ----- | ----- |
| nettype.h | 设置默认网络类型 |
| global_config.h | 全局设置 |
| stddef.h | 通用头文件 |
| isa.h | ISA头文件 |
| cpu.h | CPU头文件 |
| spm.h | SPM头文件 |
| bus.h | 总线头文件 |
| gpio.h | GPIO头文件 |
| rom.h | ROM头文件 |
| timer.h | 计时器头文件 |
| uart.h | UART头文件 |

## 更新记录

> 2020.1.31-----完成BUS总线部分verilog代码及文档编写  
> 2020.2.1-----完成ROM部分verilog代码及文档编写  
> 2020.2.6-----完成CPU顶层模块头文件编写(摸了几天鱼orz)  
> To be continued...

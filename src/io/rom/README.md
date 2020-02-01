
# SPROM(Single Port ROM)的输入输出端口(Port a)

| 信号名 | 信号类型 | 位宽 | 含义 |
| ----- | ------- | ---- | ---- |
| clka | Input | 1 | 时钟 |
| addra | Input | 实例化时决定 | 地址 |
| douta | Output | 实例化时决定 | 读取的数据 |

# 宏一览表(rom.h)

| 宏名 | Value | 含义 |  
| ----- | ------ | ---- | 
| ROM_SIZE | 8192 | ROM的大小 |
| ROM_DEPTH | 2048 | ROM的宽度 |
| ROM_ADDR_W | 11 | 地址宽度 |
| RomAddrBus | 10:0 | 地址总线 |
| RomAddrLoc | 10:0 | 地址的位置 |

# 信号线一览表(rom.v)

## CLK & RESET

| 信号名 | 信号类型 | 数据类型 | 位宽 | 含义 |
| ------ | ------- | ------- | ---- | --- |
| clk | Input | wire | 1 | 时钟 |
| reset | Input | wire | 1 | 异步复位 | 

## 总线接口

| 信号名 | 信号类型 | 数据类型 | 位宽 | 含义 |
| ------ | ------- | ------- | ---- | --- |
| cs_ | Input | wire | 1 | 片选信号 |
| as_ | Input | wire | 1 | 地址选通 | 
| addr | Input | wire | 11 | 地址 | 
| rd_data | Output | wire | 32 | 读取的数据 |
| rdy_ | Output | reg | 1 | 就绪信号 | 



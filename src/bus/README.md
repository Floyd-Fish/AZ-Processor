
# 总线模块一览表

| 模块名 | 文件名 | 说明 |  
| ----- | ------ | ---- |  
| bus | bus.v | 总线顶层模块 |  
| bus_arbiter | bus_arbiter.v | 总线仲裁器 |  
| bus_addr_dec | bus_addr_dec.v | 地址解码器 |  
| bus_master_mux | bus_master_mux.v | 总线主控多路复用器 |  
| bus_slave_mux | bus_slave_mux.v | 总线从属用多路复用器 |  

# 宏一览表(bus.h)

| 宏名 | Value | 含义 |  
| ----- | ------ | ---- | 
| BUS_MASTER_CH | 4 | 总线主控通道数 |
| BUS_MASTER_INDEX_W | 2 | 总线主控索引宽度 |
| BusOwnerBus | 1:0 | 总线所有权状态总线 |
| BUS_OWNER_MASTER_0 | 2'h0 | 总线使用权所有者: 0号主线总控 |
| BUS_OWNER_MASTER_1 | 2'h1 | 总线使用权所有者: 1号主线总控 |
| BUS_OWNER_MASTER_2 | 2'h2 | 总线使用权所有者: 2号主线总控 |
| BUS_OWNER_MASTER_2 | 2'h3 | 总线使用权所有者: 3号主线总控 |
| BUS_SLAVE_CH | 8 | 总线从属通道数 |
| BUS_SLAVE_INDEX_W | 3 | 总线从属索引宽度 |
| BusSlaveIndexBus | 2:0 | 总线从属索引总线 |
| BusSlaveIndexLoc | 29:27 |总线从属索引的位置 |
| BUS_SLAVE_0 | 0 | 0号总线从属 |
| BUS_SLAVE_1 | 1 | 1号总线从属 |
| BUS_SLAVE_2 | 2 | 2号总线从属 |
| BUS_SLAVE_3 | 3 | 3号总线从属 |
| BUS_SLAVE_4 | 4 | 4号总线从属 |
| BUS_SLAVE_5 | 5 | 5号总线从属 |
| BUS_SLAVE_6 | 6 | 6号总线从属 |
| BUS_SLAVE_7 | 7 | 7号总线从属 |

# 总线的地址映射
AZ-Pr的总线连接到8个总线从属通道，所以单纯地将地址空间8等分，再分配给0号总线从属到7号总线从属。下表列出其地址映射关系。  

| 总线从属 | 地址 | 地址最高三位 | 分配对象(才不给你分配) |
| ------- | ---- | ----------- | -------------------- |
| 0号 | 0x0000_0000 - 0x1FFF_FFFF | 3'b000 | 只读存储器ROM |
| 1号 | 0x2000_0000 - 0x3FFF_FFFF | 3'b001 | 暂时存储器SPM |
| 2号 | 0x4000_0000 - 0x5FFF_FFFF | 3'b010 | 计时器 |
| 3号 | 0x6000_0000 - 0x7FFF_FFFF | 3'b011 | UART |
| 4号 | 0x8000_0000 - 0x9FFF_FFFF | 3'b100 | GPIO |
| 5号 | 0xA000_0000 - 0xBFFF_FFFF | 3'b101 | 未分配(单身) |
| 6号 | 0xC000_0000 - 0xDFFF_FFFF | 3'b110 | 未分配(单身) |
| 7号 | 0xE000_0000 - 0xFFFF_FFFF | 3'b111 | 未分配(单身) |

# 信号一览表(bus_arbiter.v)

## 时钟复位  

| 信号名 | 信号类型 | 数据类型 | 位宽 | 含义 |
| ------ | ------- | ------- | ---- | --- |
| clk | Input | wire | 1 | 时钟 |
| reset | Input | wire | 1 | 异步复位 |

## 'x'号总线主控(x = 1, 2, 3, 4)

| 信号名 | 信号类型 | 数据类型 | 位宽 | 含义 |
| ------ | ------- | ------- | ---- | --- |
| mx_req_ | Input | wire | 1 | 请求总线x |
| mx_grnt_ | Output | reg | 1 | 赋予总线x |

## 内部信号

| 信号名 | 信号类型 | 数据类型 | 位宽 | 含义 |
| ------ | ------- | ------- | ---- | --- |
| owner | Internal | reg | 2 | 总线使用权所有者 |

# 信号二览表(bus_master_mux.v)

## 'x'号总线主控(x = 1, 2, 3, 4)

| 信号名 | 信号类型 | 数据类型 | 位宽 | 含义 |
| ------ | ------- | ------- | ---- | --- |
| mx_addr | Input | wire | 30 | 地址 |
| mx_as_ | Input | wire | 1 | 地址选通 |
| mx_rw | Input | wire | 1 | 读/写 |
| mx_wr_data | Input | wire | 32 | 写入的数据 |
| mx_grnt_ | Input | wire | 1 | 赋予总线 |

## 共享信号总线从属  
| 信号名 | 信号类型 | 数据类型 | 位宽 | 含义 |
| ------ | ------- | ------- | ---- | --- |
| s_addr | Output | reg | 30 | 地址 |
| s_as_ | Output | reg | 1 | 地址选通 |
| s_rw | Output | reg | 1 | 读/写 |
| s_we_data | Output | reg | 32 | 写入的数据 |

# 信号三览表(bus_addr_dec.v)

| 分组 | 信号名 |信号类型 | 数据类型 | 位宽 | 含义 |
| ---- | ----- | ------ | ------- | ---- | ---- |
| 总线从属共享信号 | s_addr | Input | wire | 30 | 地址| 
| 0号总线从属 | s0_cs_ | Output | reg | 1 | 片选 |
| 1号总线从属 | s1_cs_ | Output | reg | 1 | 片选 |
| 2号总线从属 | s2_cs_ | Output | reg | 1 | 片选 |
| 3号总线从属 | s3_cs_ | Output | reg | 1 | 片选 |
| 4号总线从属 | s4_cs_ | Output | reg | 1 | 片选 |
| 5号总线从属 | s5_cs_ | Output | reg | 1 | 片选 |
| 6号总线从属 | s6_cs_ | Output | reg | 1 | 片选 |
| 7号总线从属 | s7_cs_ | Output | reg | 1 | 片选 |
| 内部信号 | s_index | Internal | wire | 3 |总线从属的索引 |

# 信号四览表(bus_slave_mux.v)

## 总线从属多路复用器('x'号总线从属(x = 0, 1, ..., 7))
| 分组 | 信号名 |信号类型 | 数据类型 | 位宽 | 含义 |
| ---- | ----- | ------ | ------- | ---- | ---- |
| x号总线从属 | sx_cs_ | Input | wire | 1 | 片选 |
| x号总线从属 | sx_rd_data | Input | wire | 32 | 读出的数据 |
| x号总线从属 | sx_rdy_ | Input | wire | 1 | 就绪 |
| 总线主控共享信号 | m_rd_data | Output | reg | 32 | 读出的数据 |
| 总线主控共享信号 | m_rdy—— | Output | reg | 1 | 就绪 |

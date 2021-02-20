# 1. 基于FPGA的PMSM模型预测控制算法加速
- a 2021_CN_WinterCamp project：

  学习使用HLS工具对FCS-MPC算法加速 ，并在Zedboard和EDDP平台上进行验证。
***

##  1.1. FCS-MPC算法基本原理
  根据控制量的不同, FCS-MPC可分为电流模型预测控制(MPCC)和转矩模型预测控制( MPTC). MPTC不但需要对转矩和磁链进行估测，还需要平衡转矩和磁链之间的控制性能，在价值函数中设置合适的加权因子，使MPTC灵活性受到影响。MPCC不需要对转矩和磁链进行估算和预测，计算量较小，可以通过提高采样频率或者增加预测步长提高系统性能. 本项目关注于单步电流模型预测控制算法的加速.

  d-q旋转坐标系永磁同步电机动态数学模型如下式所示：
  $$ \frac{d i_{d}(t)}{d t}=\frac{1}{L_{d}}\left(v_{d}(t)-R i_{d}(t)+\omega_{e}(t) L_{q} i_{q}(t)\right)\tag{1}$$

  $$\frac{d i_{q}(t)}{d t}=\frac{1}{L_{q}}\left(v_{q}(t)-R i_{q}(t)-\omega_{e}(t) L_{d} i_{d}(t)-\omega_{e}(t) \phi_{m g}\right)\tag{2}$$

  在$t_{i}$时刻，取时间间隔$\Delta$<sub>t</sub>使：
  
  $$\frac{d i_{d}(t)}{d t} \approx \frac{i_{d}\left(t_{i+1}\right)-i_{d}\left(t_{i}\right)}{\Delta t}\tag{3}$$

  $$
  \frac{d i_{q}(t)}{d t} \approx \frac{i_{q}\left(t_{i+1}\right)-i_{q}\left(t_{i}\right)}{\Delta t}
  \tag{4}$$

  将(3)、(4)分别带入(1)、(2)式中，可得：

  $$
  i_{d}\left(t_{i+1}\right)=i_{d}\left(t_{i}\right)+\frac{\Delta t}{L_{d}}\left(v_{d}\left(t_{i}\right)-R i_{d}\left(t_{i}\right)+\omega_{e}\left(t_{i}\right) L_{q} i_{q}\left(t_{i}\right)\right)
  \tag{5}$$

  $$
  i_{q}\left(t_{i+1}\right)=i_{q}\left(t_{i}\right)+\frac{\Delta t}{L_{q}}\left(v_{q}\left(t_{i}\right)-R i_{q}\left(t_{i}\right)-\omega_{e}\left(t_{i}\right) L_{d} i_{d}\left(t_{i}\right)-\omega_{e}\left(t_{i}\right) \phi_{m g}\right)
  \tag{6}$$

  为了便于编程实现，将(5)、(6)改写成下式形式：

  $$
  \left[\begin{array}{c}
  i_{d}\left(t_{i+1}\right) \\
  i_{q}\left(t_{i+1}\right)
  \end{array}\right]=\left(I+\Delta t A_{m}\left(t_{i}\right)\right)\left[\begin{array}{c}
  i_{d}\left(t_{i}\right) \\
  i_{q}\left(t_{i}\right)
  \end{array}\right]-\left[\begin{array}{c}
  0 \\
  \frac{\omega_{e}\left(t_{i}\right) \phi_{m g} \Delta t}{L_{q}}
  \end{array}\right]+\Delta t B_{m}\left[\begin{array}{c}
  v_{d}\left(t_{i}\right) \\
  v_{q}\left(t_{i}\right)
  \end{array}\right]
  \tag{7}$$

  其中

  $$
  A_{m}\left(t_{i}\right)=\left[\begin{array}{cc}
  -\frac{R_{s}}{L_{d}} & \frac{\omega_{e}\left(t_{i}\right) L_{q}}{L_{d}} \\
  -\frac{\omega_{e}\left(t_{i}\right) L_{d}}{L_{q}} & -\frac{R_{s}}{L_{q}}
  \end{array}\right]
  $$
  $$
  B_{m}=\left[\begin{array}{cc}
  \frac{1}{L_{d}} & 0 \\
  0 & \frac{1}{L_{q}}
  \end{array}\right]
  $$
  cost function采用下式形式：
  $$
  J(k)=\left(i_{d}(k)-i_{d}^{*}\right)^{2}+\left(i_{q}(k)-i_{q}^{*}\right)^{2}+\lambda_{u}\|\Delta u(k)\|_{1}
  \tag{8}$$


## 1.2. 延迟补偿及算法实现流程
  在非理想情况下，存在如下几种延迟：
  - Measurement delay:在EDDP中，该部分延迟主要由sinc3 filter引起，当ad7403的驱动时钟为20MHZ时，不同的抽取率引起的延迟如下表所示：
  
  | Decimation Ratio(R) | Throught Rate(KHZ) | Effective Number of bit(ENOB) | Filter Delay(us) |
  | :-----------------: | :----------------: | :---------------------------: | :--------------: |
  |         256         |        78.1        |              12               |       12.8       |
  |         128         |       156.2        |              11               |       6.4        |
  |         32          |        625         |               9               |       1.6        |
  
  由上表可知电流采样信号链延迟最低为1.6微秒。
  - Uplink communication delay:上行链路延迟，指测量结果传递至MPC计算单元的延迟，该部分延迟主要由clark变换IP核、park变换IP核引起。
  - Computation delay:计算延迟，该部分延迟主要由计算单元引起，未经HLS加速的MPC算法计算延迟为584us。
  - Downlink delay:下行链路延迟，MPC求解出的最优开关位置信号后经过SN74LVC1G97DCK/ADUM4224触发MOSFET动作引起的延迟。查询datasheet可得该部分延迟在200ns以下。
  通信和计算延迟通常为最重要的延迟。在数字控制器中，通常需要对延迟进行补偿。下图中U和D分别表示上行通信延迟和下行通信延迟，C表示MPC计算单元延迟。垂直箭头表示测量采样和开关实际作用的时间点。
  ![图1.1 未补偿延迟的模型预测控制算法](https://github.com/zhang-jinyu/IIoT-SPYN/blob/2021_CN_WinterCamp/picture/%E6%9C%AA%E8%A1%A5%E5%81%BF%E5%BB%B6%E8%BF%9F%E7%9A%84%E6%83%85%E5%86%B5.png)
  
  未补偿前，由于延迟时间的存在，使得本应在第k时刻作用于功率器件的开关组合U(K,K)却在第K+1时刻才作用于功率器件。这种开关位置作用时间的滞后，增加了电流纹波，降低了模型预测控制的闭环性能。为此，数字电路中，通常会引入额外的预测步长对延迟进行补偿。即，使用第k-1步的电流$i_{s}(k-1)$以及作用于k-1步的开关位置$U(k-1|k-2)$预测第k步的电流。
  $$
  \boldsymbol{i}_{s}(k \mid k-1)=\boldsymbol{A} \boldsymbol{i}_{s}(k-1)+\boldsymbol{B} \boldsymbol{u}(k-1 \mid k-2)
  \tag{9}$$
  根据上式，为模型预测算法增加额外的初始状态预测，具体预测步骤如下所示：

  0. 完成对第K-1步定子电流采样，并使用式9计算第k步的电流值$i_{s}(k|k-1)$.
  1. 进一步缩小第K步开关位置$U(K|K-1)$的开关位置范围。
  2. 对于候选$u(k|k-1)$使用式(8)计算J。
  3. 将对应最小价值函数$J_{min}$的$u_{opt}(k|k-1)$作用于逆变器。
  
  经延迟补偿的模型预测算法计算过程如下图所示：
  ![图1.2 延迟补偿模型预测算法](https://github.com/zhang-jinyu/IIoT-SPYN/blob/2021_CN_WinterCamp/picture/%E5%A2%9E%E5%8A%A0%E5%BB%B6%E8%BF%9F%E8%A1%A5%E5%81%BF.png)

## 1.3. 基于Vivado HLS的FCS-MPC算法加速
  模型预测控制算法的实现主要是在Vivado HLS和Vivado两个EDA设计工具中完成。首先由Vivado HLS部分完成模型预测控制算法部分进行加速，该部分完成的是实现C++高级语言到寄存器级硬件描述语言（Verilog）的转化，并将其封装成后续可进行图形化模块设计的IP核；然后在Vivado设计套件中完成矢量控制的基于IP核的模块化设计（Block Design）进而完成寄存器传输级（RTL）到比特流的FPGA设计。基于HLS的模型预测控制算法设计流程如下图所示。
  ![模型预测控制算法设计流程](https://github.com/zhang-jinyu/IIoT-SPYN/blob/2021_CN_WinterCamp/picture/%E6%A8%A1%E5%9E%8B%E9%A2%84%E6%B5%8B%E6%8E%A7%E5%88%B6%E7%AE%97%E6%B3%95%E8%AE%BE%E8%AE%A1%E6%B5%81%E7%A8%8B.png)
  
  使用Vivado HLS对FCS-MPC算法加速分为如下步骤：
  1. Initial Optimizations:初始优化，该部分的主要任务为定义接口
  2. Pipline for Performance：对loop和function进行流水线化处理，尽可能多的对数据进行并行处理，提升性能。
  3. Optimize Structures：优化结构，对RAM和port进行partition；清除错误依存关系。
  4. Reduce Latency：缩短时延
  5. Improve Area：改善面积，通过复用硬件资源来改善面积占用。
### 1.3.1. Initial Optimizqations
  对算法进行仿真验证和综合完成之后，接下来首先要做的工作是定义接口。接口是指为顶层函数实参指定I/O协议。Vivado HLS支持两种接口协议：**Block Level Protocol**和**Port Level Protocol**。

- **Block Level I/O Protocol** 该接口协议主要是为HLS block生成握手信号和控制信号。**Block Level Protocol**包含**ap_control_none** 、**ap_control_hs** 、**ap_control_chain**三种类型接口协议，其中ap_control_hs为默认设置。
  
  1. **ap_control_hs** 该接口协议通常包含如下接口信号：
     - **ap_start** 表示该功能模块何时开始处理数据
     - **ap_idle** 表示该功能模块何时处于空闲状态
     - **ap_done** 表示是否已经完成特定运算功能
     - **ap_ready** 表示何时该功能模块能够接收新的输入数据。
  
  2. **ap_control_chain** 该接口协议与ap_control_hs相似，只比ap_control_hs多一个ap_continue输入信号。当ap_continue信号为低电平时，表示下级block未准备就绪接收新的数据；暂停向下级bolck传输新的数据。
  3. **ap_control_none** 对接口应用该协议类型时，不会产生任何与该接口相关的控制信号。

- **Port Level I/O Protocol** 当使用Block level protocol对block实现控制之后，需要使用Port Level Protocol实现Block的数据传输。Port Level Protocol 包含：
  1.  AXI4 Interface Protocol
        - AXI4-Lite Interfaces(**s_axilite**)
        - AXI4-Master Interfaces(**m_axi**)
        - AXI4-Stream Interfaces(**axis**)
  2. No I/O Protocol
  3. Wire Handshake Protocol
  4. Memory Interface Protocol
  5. Bus Protocol
### 1.3.2. Pipline for Performance 

### 1.3.3. Optimize Structures

### 1.3.4. Reduce Latency

### 1.3.5. Improve Area
  



##  目前已完成的工作

  ###  修正电流采样信号链

  ###  转子转速位置信号链改进

  ###  模型预测控制的延迟补偿修正



##  目前仍需解决的问题

###  解决过流导致的ap_start仅能保持一个时钟周期的问题
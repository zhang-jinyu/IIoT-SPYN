# 基于FPGA的PMSM模型预测控制算法加速
- a 2021_CN_WinterCamp project：

  学习使用HLS工具对FCS-MPC算法加速 ，并在Zedboard和EDDP平台上进行验证。
***

##  1.1. 项目介绍

### 1.1.1. FCS-MPC算法基本原理
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


### 1.1.2. 延迟补偿
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
  ![图1.1未补偿前采样计算作用点](https://github.com/zhang-jinyu/IIoT-SPYN/blob/2021_CN_WinterCamp/picture/%E6%9C%AA%E8%A1%A5%E5%81%BF%E5%BB%B6%E8%BF%9F%E7%9A%84%E6%83%85%E5%86%B5.png)


### 1.1.3. 基于xilinx zynq的PMSM模型预测控制器设计流程
## 1.2. 目前已完成的工作

  ### 1.2.1. 修正电流采样信号链

  ### 1.2.2. 转子转速位置信号链改进

  ### 1.2.3. 模型预测控制的延迟补偿修正



## 1.3. 目前仍需解决的问题

### 1.3.1. 解决过流导致的ap_start仅能保持一个时钟周期的问题
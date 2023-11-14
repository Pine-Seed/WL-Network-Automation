#!/bin/bash

interface_one="wlan0"  # wan口1：对接校园网
interface_two="wlan0-1"  # wan口2：客户端路由
target_ssid_one="Campus Network Wireless SSID"  # 校园网无线SSID
target_ssid_two="Wireless SSID"  # 无线SSID
username="Campus Network Account"  # 校园网账号
password="Campus network password"  # 校园网密码

# LED灯光配置:需提前在OpenWrt的LED中添加一个配置(只允许存在一个配置)触发器:自定义,通电时间:500
# 此Led通过小米路由器3C测试，其他路由器等设备未测试，但是未配置LED也不妨碍本脚本使用
led_configuration() {
  uci set system.@led[0].sysfs='$1'  # 颜色
  uci set system.@led[0].delayoff='$2'  # 间隔时间
  /etc/init.d/led restart
}

led_configuration 'amber:status' '0'

# 检测接口与WIFI状态
wifi_count_start=1
while true; do
  ssid_one=$(iwinfo "$interface_one" info | grep -o 'ESSID: ".*"' | cut -d" " -f2)
  ssid_two=$(iwinfo "$interface_two" info | grep -o 'ESSID: ".*"' | cut -d" " -f2)
  if [ "$ssid_one" = "\"$target_ssid_one\"" ] && [ "$ssid_two" = "\"$target_ssid_two\"" ]; then
    echo "[INFO]["$(date +"%Y-%m-%d %H:%M:%S")"]:""WAN interface connected to corresponding WIFI" >> /root/pineseed.log  # WAN接口已连接至对应WIFI
    break
  else
    echo "[ERROR]["$(date +"%Y-%m-%d %H:%M:%S")"]:""WAN interface not connected to corresponding WIFI" >> /root/pineseed.log  # WAN接口未连接至对应WIFI
    led_configuration 'red:status' '500'
    if [ "$wifi_count_start" == 10 ]; then
      echo "["$(date +"%Y-%m-%d %H:%M:%S")"]:""Attempting to restart the device" >> /root/pineseed.log  # 正在尝试重新启动设备
      led_configuration 'red:status' '0'
      sleep 3
      reboot
      exit 1
    fi
    wifi_count_start=$((wifi_count_start + 1))
    sleep 2
  fi
done

led_configuration 'amber:status' '0'

# 检测校园网终端状态
ping_count_start=1
while true; do
  ping -c 1 "192.168.240.3"  # 此处可修改为自己学校的校园网IP
  if [ $? -eq 0 ]; then
    echo "[INFO]["$(date +"%Y-%m-%d %H:%M:%S")"]:""Campus network terminal is normal" >> /root/pineseed.log  # 校园网终端正常
    break
  else
    echo "[ERROR]["$(date +"%Y-%m-%d %H:%M:%S")"]:""Abnormal campus network terminal" >> /root/pineseed.log  # 校园网终端异常
    led_configuration 'red:status' '500'
    if [ "$ping_count_start" == 10 ]; then
      echo "["$(date +"%Y-%m-%d %H:%M:%S")"]:""Attempting to restart the device" >> /root/pineseed.log  # 正在尝试重新启动设备
      led_configuration 'red:status' '0'
      sleep 3
      reboot
      exit 1
    fi
    ping_count_start=$((ping_count_start + 1))
    sleep 2
  fi
done

# 检测网络连接状态
ping_count_start=1
while true; do
  ping -c 1 "www.baidu.com"
  if [ $? -eq 0 ]; then
    echo "[INFO]["$(date +"%Y-%m-%d %H:%M:%S")"]:""Network connected" >> /root/pineseed.log  # 已连接到网络
    break
  else
    echo "[ERROR]["$(date +"%Y-%m-%d %H:%M:%S")"]:""Not connected to the network" >> /root/pineseed.log  # 未连接到网络
    led_configuration 'red:status' '500'
    curl "http://192.168.240.3/drcom/login?callback=dr1696842789462&DDDDD=$username&upass=$password&0MKKey=123456&R1=0&R3=0&R6=0&para=00&v6ip=&_=1696842756132"  # 此处可修改为自己校园的校园网登录请求网址
    if [ "$ping_count_start" == 3 ]; then
      echo "["$(date +"%Y-%m-%d %H:%M:%S")"]:""Attempting to restart the device" >> /root/pineseed.log  # 正在尝试重新启动设备
      led_configuration 'red:status' '0'
      sleep 3
      reboot
      exit 1
    fi
    ping_count_start=$((ping_count_start + 1))
    sleep 5
  fi
done

led_configuration 'blue:status' '0'

exit 0
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

username="Campus Network Account"  # 校园网账号
password="Campus network password"  # 校园网密码

# 检测网络连接状态
ping_count_start=1
while true; do
  ping -c 1 "www.baidu.com"
  if [ $? -eq 0 ]; then
    echo "[START][INFO]["$(date +"%Y-%m-%d %H:%M:%S")"]:""Network connected" >> /root/pineseed.log  # 已连接到网络
    break
  else
    echo "[START][ERROR]["$(date +"%Y-%m-%d %H:%M:%S")"]:""Not connected to the network" >> /root/pineseed.log  # 未连接到网络
    curl "http://192.168.240.3/drcom/login?callback=dr1696842789462&DDDDD=$username&upass=$password&0MKKey=123456&R1=0&R3=0&R6=0&para=00&v6ip=&_=1696842756132"  # 此处可修改为自己学校的校园网登录请求网址
    if [ "$ping_count_start" == 5 ]; then
      break
    fi
    ping_count_start=$((ping_count_start + 1))
    sleep 5
  fi
done

exit 0

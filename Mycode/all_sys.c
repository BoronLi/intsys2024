#include <stdio.h>
#include <wiringPi.h>
#include <wiringPiI2C.h>
#include <string.h>
#include <sys/time.h>

#define makerobo_Trig    28   // 超声波模块Tring控制管脚
#define makerobo_Echo    29   // 超声波模块Echo控制管脚

int makerobo_LCDAddr = 0x27;   // LCD 1602 液晶IIC地址 0x27或者0x3F
int makerobo_BLEN = 1;         // 写入标志位
int makerobo_fd;

// 超声波模块初始化工作
void makerobo_ultraInit(void)
{
	pinMode(makerobo_Echo, INPUT);    // Echo设置为输入模式
	pinMode(makerobo_Trig, OUTPUT);   // Tring设置为输出模式
}

// 超声波计算距离函数
float ur_disMeasure(void)
{
	struct timeval ur_tv1;         // 定义时间结构体变量ur_tv1
	struct timeval ur_tv2;         // 定义时间结构体变量ur_tv2
	long ur_time1, ur_time2;          // 定义两个长整型时间变量ur_time1,ur_time2
    float ur_dis;                  // 定义距离变量

	digitalWrite(makerobo_Trig, LOW);  // 开始起始   
	delayMicroseconds(2);              // 延时2us

	digitalWrite(makerobo_Trig, HIGH); // 超声波启动信号，延时10us
	delayMicroseconds(10);            //发出超声波脉冲
	digitalWrite(makerobo_Trig, LOW); // 设置为低电平
								
	while(!(digitalRead(makerobo_Echo) == 1));   // 等待回传信号
	gettimeofday(&ur_tv1, NULL);                          //获取当前时间

	while(!(digitalRead(makerobo_Echo) == 0));           // 回传信号截止信息
	gettimeofday(&ur_tv2, NULL);                         //获取当前时间

	ur_time1  = ur_tv1.tv_sec * 1000000 + ur_tv1.tv_usec;     // 转换微秒级的时间
	ur_time2  = ur_tv2.tv_sec * 1000000 + ur_tv2.tv_usec;     // 转换为微秒级时间
    // 声速在空气中的传播速度为340m/s, 超声波要经历一个发送信号和一个回波信息，
	// 计算公式如下所示：
	ur_dis = (float)(ur_time2 - ur_time1) / 1000000 * 34000 / 2;  //求出距离

	return ur_dis;  // 返回距离值
}

// IIC LCD1602 液晶模块写入字
void makerobo_write_word(int data){
	int temp = data;
	if ( makerobo_BLEN == 1 )
		temp |= 0x08;
	else
		temp &= 0xF7;
	wiringPiI2CWrite(makerobo_fd, temp);   //设置IIC LCD1602 液晶模块地址
}
// IIC LCD1602 发送命令
void makerobo_send_command(int comm){
	int lcd_buf;
	// 首先发送 bit7-4 位
	lcd_buf = comm & 0xF0;
	lcd_buf |= 0x04;			// RS = 0, RW = 0, EN = 1
	makerobo_write_word(lcd_buf);
	delay(2);
	lcd_buf &= 0xFB;			// Make EN = 0
	makerobo_write_word(lcd_buf);

	// 其次发送 bit3-0 位
	lcd_buf = (comm & 0x0F) << 4;
	lcd_buf |= 0x04;			// RS = 0, RW = 0, EN = 1
	makerobo_write_word(lcd_buf);
	delay(2);
	lcd_buf &= 0xFB;			// Make EN = 0
	makerobo_write_word(lcd_buf);
}
// IIC LCD1602 发送数据
void makerobo_send_data(int data){
	int lcd_buf;
	// 首先发送 bit7-4 位
	lcd_buf = data & 0xF0;
	lcd_buf |= 0x05;			// RS = 1, RW = 0, EN = 1
	makerobo_write_word(lcd_buf);
	delay(2);
	lcd_buf &= 0xFB;			// Make EN = 0
	makerobo_write_word(lcd_buf);

	// 其次发送 bit3-0 位
	lcd_buf = (data & 0x0F) << 4;
	lcd_buf |= 0x05;			// RS = 1, RW = 0, EN = 1
	makerobo_write_word(lcd_buf);
	delay(2);
	lcd_buf &= 0xFB;			// Make EN = 0
	makerobo_write_word(lcd_buf);
}
// IIC LCD1602 初始化
void makerobo_init(){
	makerobo_send_command(0x33);	// 必须先初始化到8线模式吗
	delay(5);
	makerobo_send_command(0x32);	// 然后初始化为4行模式
	delay(5);
	makerobo_send_command(0x28);	// 2 行 & 5*7 点位
	delay(5);
	makerobo_send_command(0x0C);	// 启用无光标显示
	delay(5);
	makerobo_send_command(0x01);	// 清除显示
	wiringPiI2CWrite(makerobo_fd, 0x08);
}
// LCD 1602 清空显示函数
void makerobo_clear()
{
	makerobo_send_command(0x01);	// 清除显示
}
// LCD 1602 显示函数
void makerobo_write(int lcd_x, int lcd_y, char data[]){
	int lcd_addr, lcd_i;
	int lcd_tmp;
	// 选择行与列
	if (lcd_x < 0)  lcd_x = 0;
	if (lcd_x > 15) lcd_x = 15;
	if (lcd_y < 0)  lcd_y = 0;
	if (lcd_y > 1)  lcd_y = 1;

	// 移动光标
	lcd_addr = 0x80 + 0x40 * lcd_y + lcd_x;
	
	makerobo_send_command(lcd_addr); //发送地址
	
	lcd_tmp = strlen(data);         // 获取字符串长度
	for (lcd_i = 0; lcd_i < lcd_tmp; lcd_i++){  // 依次发送
		makerobo_send_data(data[lcd_i]);    // 逐一显示
	}
}


void lcdshow_ur_dis(void)
{
	float ur_dis;  //定义一个局部变量，保存距离值
	unsigned char  len,temp[10];

   // 初始化连接失败时，将消息打印到屏幕
	if(wiringPiSetup() == -1){ 
		printf("setup wiringPi failed !");
		return 1; 
	}

	makerobo_ultraInit();  // 调用超声波模块初始化工作
	
	ur_dis = ur_disMeasure();    //获取超声波计算距离
	printf("%0.2f cm\n\n",ur_dis);  //打印超声波距离值
    ur_dis_char = sprintf((char *)temp,"%0.2f",ur_dis);
    makerobo_write(0, 0, ur_dis_char);                    //第一行显示

	return ur_dis;
}

// 主函数
int main(){

    //初始化
	makerobo_fd = wiringPiI2CSetup(makerobo_LCDAddr);  //初始化地址
	makerobo_init();                                   //初始化显示屏
	//主函数
    while(1)
	{
		//makerobo_write(0, 0, "Hello!");                    //第一行显示
		//makerobo_write(0, 1, "Makerobo kit");              //第二行显示
		lcdshow_ur_dis();
        delay(2000);                                      // 延时2s
		makerobo_clear();                                 // 清空显示
	}
	return 0;
}

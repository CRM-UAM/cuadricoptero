/*
 * GPS.h
 *
 *  Created on: 20 juin 2013
 *      Author: WEYEE
 */

#ifndef GPS_H_
#define GPS_H_

extern int32_t wrap_18000(int32_t ang);

void GPS_set_pids(void);
void GPS_SerialInit(void);
void GPS_NewData(void);
void GPS_reset_home_position(void);
void GPS_set_next_wp(int32_t* lat_to, int32_t* lon_to, int32_t* lat_from, int32_t* lon_from);
void GPS_reset_nav(void);
void GPS_Process_data(void);

int32_t get_altitude_error();
void clear_new_altitude();
void force_new_altitude(int32_t _new_alt);
void set_new_altitude(int32_t _new_alt);
int32_t get_new_altitude();
void abort_mission(unsigned char error_code);
void GPS_adjust_heading();
void init_RTH(void);
void check_land(void);
#if defined(I2C_GPS)
  void GPS_I2C_command(uint8_t command, uint8_t wp);
  void GPS_Process_I2C(void);
  extern int16_t target_bearing;
#else
extern uint32_t wp_distance;
extern int32_t target_bearing;
#endif

#endif /* GPS_H_ */

/*
* Copyright (c) 2017-2018 Subhadeep Jasu (https://github.com/subhadeepjasu)
* Copyright (c) 2017-2018 Saunak Biswas (https://github.com/saunakbis97)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Saunak Biswas <saunakbis97@gmail.com>
*/


namespace Pebbles
{
    public class DateFormatted {
        public int day;
        public int week;
        public int month;
        public int year;
        public DateFormatted() {
            day = 0;
            week = 0;
            month = 0;
            year = 0;
        }
    }
    public class DateCalculator {
        public string date_difference(DateTime start_date_time,DateTime end_date_time) {
            Date start_date = Date();
            start_date.set_dmy( (DateDay)start_date_time.get_day_of_month () , start_date_time.get_month() , (DateYear)start_date_time.get_year() );
            Date end_date = Date();
            end_date.set_dmy( (DateDay)end_date_time.get_day_of_month () , end_date_time.get_month() , (DateYear)end_date_time.get_year() );
            return (start_date.days_between(end_date)).to_string();
        }
        public DateFormatted difference_formatter(DateTime start_date_time,DateTime end_date_time) {
            DateFormatted date_formatted = new DateFormatted();
            Date start_date = Date();
            Date end_date = Date();
            start_date.set_dmy( (DateDay)start_date_time.get_day_of_month(), start_date_time.get_month(), (DateYear)start_date_time.get_year());
            end_date.set_dmy( (DateDay)end_date_time.get_day_of_month(), end_date_time.get_month(), (DateYear)end_date_time.get_year());
            
            while(start_date.compare(end_date) <= 0) {
                start_date.add_years(1);
                date_formatted.year = date_formatted.year + 1;
            }
            start_date.subtract_years(1);
            date_formatted.year = date_formatted.year - 1;
            while(start_date.compare(end_date) <= 0) {
                start_date.add_months(1);
                date_formatted.month = date_formatted.month + 1;
            }
            start_date.subtract_months(1);
            date_formatted.month = date_formatted.month - 1;
            date_formatted.week = (int)((start_date.days_between(end_date)) / 7);
            date_formatted.day = (start_date.days_between(end_date)) % 7;
            return date_formatted;
        }
        public Date add_to_date(DateTime start_date_time,int days_to_add,int months_to_add,int years_to_add) {
            Date added_date = Date();
            added_date.set_dmy( (DateDay)start_date_time.get_day_of_month () , start_date_time.get_month() , (DateYear)start_date_time.get_year() );
            added_date.add_days(days_to_add);
            added_date.add_months(months_to_add);
            added_date.add_years(years_to_add);
            return added_date;
        }
        public Date subtract_from_date(DateTime start_date_time,int days_to_subtract,int months_to_subtract,int years_to_subtract) {
            Date subtracted_date = Date();
            subtracted_date.set_dmy( (DateDay)start_date_time.get_day_of_month () , start_date_time.get_month() , (DateYear)start_date_time.get_year() );
            subtracted_date.subtract_days(days_to_subtract);
            subtracted_date.subtract_months(months_to_subtract);
            subtracted_date.subtract_years(years_to_subtract);
            return subtracted_date;
        }
        public string format_month_value(Date date) {
            string month = "";
            if(date.get_month() == 1) {
                month="JANUARY";
            }
            else if(date.get_month() == 2) {
                month="FEBRUARY";
            }
            else if(date.get_month() == 3) {
                month="MARCH";
            }
            else if(date.get_month() == 4) {
                month="APRIL";
            }
            else if(date.get_month() == 5) {
                month="MAY";
            }
            else if(date.get_month() == 6) {
                month="JUNE";
            }
            else if(date.get_month() == 7) {
                month="JULY";
            }
            else if(date.get_month() == 8) {
                month="AUGUST";
            }
            else if(date.get_month() == 9) {
                month="SEPTEMBER";
            }
            else if(date.get_month() == 10) {
                month="OCTOBER";
            }
            else if(date.get_month() == 11) {
                month="NOVEMBER";
            }
            else if(date.get_month() == 12) {
                month="DECEMBER";
            }
            return month;
        }
    }
    void main() {
        stdout.printf("End date in calculation is not included which is 1 day.\n");
        stdout.printf("This code assumes that given start date is always less then end date.\n");
        DateTime start_date_time = new DateTime( new TimeZone.local() , 2020 , 1 , 20 , 0 , 0 , 0 );
        //DIFFERENCE CALCULATION PART
        DateTime end_date_time = new DateTime( new TimeZone.local() , 2020 , 11 , 15 , 0 , 0 , 0 );
        DateCalculator date_calculator_object = new DateCalculator();
        stdout.printf("The difference in days is %s \n",date_calculator_object.date_difference( start_date_time , end_date_time ));

        //edited version of difference calculation output
        DateFormatted formatted_date_difference = date_calculator_object.difference_formatter(start_date_time , end_date_time );
        stdout.printf("The difference after formatting is Days=%s  Weeks=%s  Months=%s Years=%s \n",(formatted_date_difference.day).to_string(),(formatted_date_difference.week).to_string(),(formatted_date_difference.month).to_string(),(formatted_date_difference.year).to_string());
        //ADDER AND SUBTRACTER
        Date calculated_date;
        int days_to_add_or_subtract = 1, months_to_add_or_subtract = 1, years_to_add_or_subtract = 1;

        //ADDITION PART
        calculated_date = date_calculator_object.add_to_date(start_date_time,days_to_add_or_subtract,months_to_add_or_subtract,years_to_add_or_subtract);
        stdout.printf("After adding days,months,years the obtained Date is %s / %s / %s \n",calculated_date.get_day().to_string(),date_calculator_object.format_month_value(calculated_date),calculated_date.get_year().to_string());

        //SUBTRACTION PART
        calculated_date = date_calculator_object.subtract_from_date(start_date_time,days_to_add_or_subtract,months_to_add_or_subtract,years_to_add_or_subtract);
        stdout.printf("After subtracting days,months,years the obtained Date is %s / %s / %s \n",calculated_date.get_day().to_string(),date_calculator_object.format_month_value(calculated_date),calculated_date.get_year().to_string());
    }
}


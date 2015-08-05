
#import <Foundation/Foundation.h>

@interface Person : NSObject
@property NSString *name;
@property NSDate *DOB;
@property double age;

- (Person*)init;
- (void)name: (NSString*)name;
- (void)date: (NSDate*)date;
- (void)getAgeForDate: (NSDate*)date;
- (void)getAge;

@end

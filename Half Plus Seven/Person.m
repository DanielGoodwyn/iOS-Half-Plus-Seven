
#import "Person.h"

@implementation Person

- (Person*)init {
    self = [super init];
    if(self)
    {
        self.name = @"";
        self.DOB = [NSDate dateWithTimeIntervalSince1970:595857600];
    }
    return self;
}

- (void)name: (NSString*)name {
    self.name = name;
}

- (void)date: (NSDate*)date {
    self.DOB = date;
}

- (void)getAgeForDate: (NSDate*)date {
    float age = (((([date timeIntervalSinceNow]*-1)/365)/24)/60)/60;
    self.age = age;
}

- (void)getAge{
    float age = (((([self.DOB timeIntervalSinceNow]*-1)/365)/24)/60)/60;
    self.age = age;
}

@end

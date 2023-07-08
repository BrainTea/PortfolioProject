name = input("Enter your name: ")
weight = int(input("Enter your weight in pounds: "))
height = int(input("Enter your height in inches: "))
BMI = (weight * 703) / (height * height)

if BMI > 0:
    if(BMI < 18.5):
        print(name + ', you are underweight with a BMI of ' + str(BMI)[0:5])
    elif(BMI <= 24.9):
        print(name + ', you are normal weight with a BMI of ' + str(BMI)[0:5])
    elif(BMI <= 29.9):
        print(name + ', you are overweight with a BMI of ' + str(BMI)[0:5])
    elif(BMI <= 34.9):
        print(name + ', you are obese with a BMI of ' + str(BMI)[0:5])
    elif(BMI <= 39.9):
        print(name + ', you are severly obese with a BMI of ' + str(BMI)[0:5])
    else:
        print(name + ', you are morbidly obese with a BMI of ' + str(BMI)[0:5])
else:
    print('Enter valid inputs.')
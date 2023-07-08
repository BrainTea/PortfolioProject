import os, shutil

#Selecting folder where sorting will be done
path = r"C:/Users/Bryan/Documents/My Projects/Visual Studio Code/Python/autofilesorter/"
file_name = os.listdir(path)

#Choosing the names of folders where each file in the selected folder will go to
folder_names = ['csv files', 'image files', 'text files']

#Creates the folders if they do not exist
for loop in range(0,3):
    if not os.path.exists(path + folder_names[loop]):
        print(path + folder_names[loop])
        os.makedirs((path + folder_names[loop]))

#Looks in the selected folder and moves files to their respective folder
for file in file_name:
    if ".csv" in file and not os.path.exists(path + "csv files/" + file):
        shutil.move(path + file, path + "csv files/" + file)
    elif ".jpg" in file and not os.path.exists(path + "image files/" + file):
        shutil.move(path + file, path + "image files/" + file)
    elif ".txt" in file and not os.path.exists(path + "text files/" + file):
        shutil.move(path + file, path + "text files/" + file)
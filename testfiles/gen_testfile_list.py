import os

def gen_testfile_list(DIR_NAME):
    fw.write('\n/////////////////////   '+DIR_NAME[2:-1].upper()+'   /////////////////////\n\n')
    for fn in os.listdir(DIR_NAME):
        if fn.endswith(".elf"):
            # print(fn)
            fw.write('unit_test("' + DIR_NAME[1:] + os.path.splitext(fn)[0]+'");\n')

rfw = "./testfile_list.txt"
fw = open(rfw, "w+")

gen_testfile_list('./riscvtest/')
gen_testfile_list('./benchmark/')
gen_testfile_list('./cputest/')

print("GEN TESTFILE LIST FINISH")
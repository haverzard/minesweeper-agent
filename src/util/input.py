def process_input(file):
    data = open(file).readlines()
    size = int(data[0])
    bombs_count = int(data[1])
    coords = []
    for i in range(bombs_count):
        x, y = map(int, data[i+2].split(", "))
        coords.append((x, y))
    return size, bombs_count, coords

if __name__ == "__main__":
    print(process_input("tests/tc1.txt"))
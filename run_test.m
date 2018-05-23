clear all
close all
disp('Running the domain/analysis/support model...')

disp('While you are waiting, please enjoy our daily jumping fact sponsored by Snapple')

 X = {'It is usually claimed that the best jumper in the world is the Flea. For their size, they are longest and highest jumpers of all animals. Fleas can jump 220 times their own body length and 150 times their own body height! That would be like us jumping nearly 400m in length whilst jumping over a 250m high building… Impressive!', 'Tree Frogs can jump 150 times their own body length, putting them at the second spot for longest jumping animal in relation to body weight.', 'The Jumping Spider can jump 100 times its own body length!', 'Grasshoppers can jump 20 times their own body length!'};
 s= {'Did you know: '};
out = strcat(s, X(randi(numel(X))));
disp(out)

model = l2('test');
model.simulate(10, 'superman');
model.plot();

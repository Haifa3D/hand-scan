function poisson_surface_reconstruction(inputfile, outputfile, depth, samplesPerNode)
poisson_path = getenv('poisson_path');
command = ['"', poisson_path, '\PoissonRecon.exe" --in "', inputfile, '" --out "', outputfile,...
    '" --depth ', num2str(depth), ' --verbose --samplesPerNode ', num2str(samplesPerNode)];
[ status, cmdout ] = system(command);
end
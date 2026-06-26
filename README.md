Helper script - To configure mosfet

The purpose of the script is to accelerate design exploration, not to make design decisions on behalf of the user.

### 1: Script Inputs: Voltage gain, gm/id

The intented design flow is:

- Extract Gm from UGB and CL.
- Id is fixed from bandgap reference model
- Hence gm/id is defined.
- Target Voltage gain or speed of mosfet can then be used to determine Length from intrinsic gain vs gm/id or ft vs gm/id.
- The user is expected to run the script multiple times to achieve a desired config while considering the necessary tradeoffs.

Note: 
- Voltage gain for the mosfet i.e. gm/gds has to be extracted from desired voltage gain of circuit stage. The script does not do this.
- Transconductance of the circuit stage can be extracted from UGB not the device, but since transconductance of input device dominates in many types of circuits, Gm of circuit is approximated to be gm of device.
- There is variance of the order 10^-2 in gm/id wrt length (between 150nm and 10um) at the same overdrive voltage.
- Vth changes with Width, hence we get Vov from gm_id since that plot is independent of changes in Vth, then Vgs is extracted from Vov and Vth. (But why does Vth change by 50mV due to 10x change in width anyways? It shouldn't)

### Using the Script:

Find the following section in the script lookup_table.m:
```
% User inputs

gm = 15 \* 25e-04;

id = 25e-04;

gm_id = gm/id;

constraint_type = 'GM_GDS';

constraint_value = 280;
```

Constraint type chooses the target quantity, currently there are only two constraints possible gm/gds and fT. Hence, constraint value is the value of the target constraint.
Moreover with reasonable accuracy(?), Vov or Vdsat is constrained to gm/id only, hence choosing gm/id is also the same as choosing Vov or Vdsat.

### Working of the Script

Of course the design methodology has already been stated, this section is to explain the lookup, parsing of the inputs and how exactly the methodology is implemented.

The input is expected to be in the form of dat files, each dat file corresponding to one length all stored in the folder SimResults in the same directory as the script build_database.m.

The script expects 7 fields of data in the order:
- Vgs, gm, Id, Cgg, gd, Vth, Vdsat

The name of the file has to follow the format
- nmos_nch_(0-9)nm.dat
Hence, the channel length is extracted from the filename.

A single mat file is constructed from all the files, the mat file is organised in the following fashion:
    Database or Mat file
        └── Curves
                    │── Curve 1 (L=150nm)
                    │      ├── L
                    │      ├── VOV
                    │      ├── GM_ID
                    │      ├── GM_GDS
                    │      ├── VDSAT
                    │      └── FT
                    │── Curve 2 (L=400nm)
                    │── ...
The loaded mat file is a database or an object - nch_18_mac_nominal.

The script adopts gm/Id and L as its design coordinates, following Murmann's methodology. While both inversion level and channel length influence metrics such as gain and fT, inversion level cannot be reliably inferred from VOV in modern short-channel technologies. In contrast, gm/Id directly represents inversion level and current efficiency. Expressing device characteristics as functions of gm/Id and L therefore captures the primary factors governing the target parameters.

The above desgin decision is apparent in the lookup function and find_length function.

#### find_length()

The find_length() function expects four inputs:

- Database (db)
- Target quantity (quantity), such as FT or GM_GDS
- gm/id
- Target value of the chosen quantity (target)

The function first evaluates the specified quantity at the given gm/id for every characterized channel length in the database. Since the database only contains discrete gm/id points for each length, interpolation is used to obtain the value of the quantity at the requested gm/id.

This produces a set of values of the target quantity corresponding to the characterized lengths. The function then treats the quantity as a function of length and performs a second interpolation to determine the channel length that achieves the desired target value.

In summary, the procedure consists of:

- Interpolating within each length curve to obtain the target quantity at the specified gm/id.
- Interpolating across lengths to determine the length corresponding to the desired target value.

#### lookup()

The lookup() function also expects four inputs:

- Database (db)
- Quantity to be evaluated (quantity)
- gm/id
- Channel length (L)

If the specified length exactly matches one of the characterized lengths in the database, the function directly evaluates the desired quantity by interpolating within the corresponding length curve at the requested gm/id.

If the specified length lies between two characterized lengths, the function first identifies the two nearest length curves. The desired quantity is then evaluated on each curve at the given gm/id through interpolation. Finally, a second interpolation is performed between the two lengths and their corresponding quantity values to obtain the result at the requested length.

In summary, the procedure consists of:

- Interpolating within the relevant length curve(s) to obtain the quantity at the specified gm/id.
- If necessary, interpolating between neighboring lengths to obtain the quantity at the requested channel length.

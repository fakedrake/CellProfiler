function handles = IdentifyPrimAdaptThresholdC(handles)

% Help for the Identify Primary Adaptive Threshold C module: 
% Category: Object Identification
%
% This image analysis module identifies objects by applying an
% adaptive threshold to a grayscale image.  Four different methods
% (A,B,C, and D) of adaptive thresholding can be used to identify
% objects.  Applies a local threshold at each pixel across the image
% and then identifies objects which are not touching. Provides more
% accurate edge determination and slightly better separation of clumps
% and than a simple threshold; still, it is ideal for well-separated
% nuclei.
%
% Module C: the optimal thresholds are determined using the isodata
% algorithm, for distinct blocks across the image.  The resulting
% thresholds are blurred.
%
% Settings:
%
% Size range: You may exclude objects that are smaller or bigger than
% the size range you specify. A comma should be placed between the
% lower size limit and the upper size limit. The units here are pixels
% so that it is easy to zoom in on found objects and determine the
% size of what you think should be excluded.
%
% Threshold: The adaptive threshold is calculated automatically and
% varies across the image. However, you can still specify a minimum
% threshold which will be used if the automatic threshold is quite
% low. The threshold affects the stringency of the lines between the
% objects and the background. You may enter an absolute number between
% 0 and 1 for the threshold (use 'Show pixel data' to see the pixel
% intensities for your images in the appropriate range of 0 to 1), or
% you may have it calculated for each image individually by typing 0.
% There are advantages either way.  An absolute number treats every
% image identically, but an automatically calculated threshold is more
% realistic/accurate, though occasionally subject to artifacts.  The
% threshold which is used for each image is recorded as a measurement
% in the output file, so if you find unusual measurements from one of
% your images, you might check whether the automatically calculated
% threshold was unusually high or low compared to the remaining
% images.  When an automatic threshold is selected, it may
% consistently be too stringent or too lenient, so an adjustment
% factor can be entered as well. The number 1 means no adjustment, 0
% to 1 makes the threshold more lenient and greater than 1 (e.g. 1.3)
% makes the threshold more stringent.
%
% Block size: should be set large enough that every square block of
% pixels is likely to contain some background and some foreground.
% Smaller block sizes take more processing time.
%
% What does Primary mean? Identify Primary modules identify objects
% without relying on any information other than a single grayscale
% input image (e.g. nuclei are typically primary objects). Identify
% Secondary modules require a grayscale image plus an image where
% primary objects have already been identified, because the secondary
% objects' locations are determined in part based on the primary
% objects (e.g. cells can be secondary objects). Identify Tertiary
% modules require images where two sets of objects have already been
% identified (e.g. nuclei and cell regions are used to define the
% cytoplasm objects, which are tertiary objects).
%
% SAVING IMAGES: In addition to the object outlines and the
% pseudo-colored object images that can be saved using the
% instructions in the main CellProfiler window for this module,
% this module produces several additional images which can be
% easily saved using the Save Images module. These will be grayscale
% images where each object is a different intensity. (1) The
% preliminary segmented image, which includes objects on the edge of
% the image and objects that are outside the size range can be saved
% using the name: PrelimSegmented + whatever you called the objects
% (e.g. PrelimSegmentedNuclei). (2) The preliminary segmented image
% which excludes objects smaller than your selected size range can be
% saved using the name: PrelimSmallSegmented + whatever you called the
% objects (e.g. PrelimSmallSegmented Nuclei) (3) The final segmented
% image which excludes objects on the edge of the image and excludes
% objects outside the size range can be saved using the name:
% Segmented + whatever you called the objects (e.g. SegmentedNuclei)
% 
% Additional image(s) are normally calculated for display only,
% including the object outlines alone. These images can be saved by
% altering the code for this module to save those images to the
% handles structure (see the SaveImages module help) and then using
% the Save Images module.
%
% See also IDENTIFYPRIMADAPTTHRESHOLDA,
% IDENTIFYPRIMADAPTTHRESHOLDB, 
% IDENTIFYPRIMADAPTTHRESHOLDD,
% IDENTIFYPRIMTHRESHOLD, 
% IDENTIFYPRIMSHAPEDIST,
% IDENTIFYPRIMSHAPEINTENS, 
% IDENTIFYPRIMINTENSINTENS.

% CellProfiler is distributed under the GNU General Public License.
% See the accompanying file LICENSE for details.
% 
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
% 
% Authors:
%   Anne Carpenter <carpenter@wi.mit.edu>
%   Thouis Jones   <thouis@csail.mit.edu>
%   In Han Kang    <inthek@mit.edu>
%
% $Revision$

% PROGRAMMING NOTE
% HELP:
% The first unbroken block of lines will be extracted as help by
% CellProfiler's 'Help for this analysis module' button as well as Matlab's
% built in 'help' and 'doc' functions at the command line. It will also be
% used to automatically generate a manual page for the module. An example
% image demonstrating the function of the module can also be saved in tif
% format, using the same name as the module, and it will automatically be
% included in the manual page as well.  Follow the convention of: purpose
% of the module, description of the variables and acceptable range for
% each, how it works (technical description), info on which images can be 
% saved, and See also CAPITALLETTEROTHERMODULES. The license/author
% information should be separated from the help lines with a blank line so
% that it does not show up in the help displays.  Do not change the
% programming notes in any modules! These are standard across all modules
% for maintenance purposes, so anything module-specific should be kept
% separate.

% PROGRAMMING NOTE
% DRAWNOW:
% The 'drawnow' function allows figure windows to be updated and
% buttons to be pushed (like the pause, cancel, help, and view
% buttons).  The 'drawnow' function is sprinkled throughout the code
% so there are plenty of breaks where the figure windows/buttons can
% be interacted with.  This does theoretically slow the computation
% somewhat, so it might be reasonable to remove most of these lines
% when running jobs on a cluster where speed is important.
drawnow

%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%
drawnow 

% PROGRAMMING NOTE
% VARIABLE BOXES AND TEXT: 
% The '%textVAR' lines contain the variable descriptions which are
% displayed in the CellProfiler main window next to each variable box.
% This text will wrap appropriately so it can be as long as desired.
% The '%defaultVAR' lines contain the default values which are
% displayed in the variable boxes when the user loads the module.
% The line of code after the textVAR and defaultVAR extracts the value
% that the user has entered from the handles structure and saves it as
% a variable in the workspace of this module with a descriptive
% name. The syntax is important for the %textVAR and %defaultVAR
% lines: be sure there is a space before and after the equals sign and
% also that the capitalization is as shown. 
% CellProfiler uses VariableRevisionNumbers to help programmers notify
% users when something significant has changed about the variables.
% For example, if you have switched the position of two variables,
% loading a pipeline made with the old version of the module will not
% behave as expected when using the new version of the module, because
% the settings (variables) will be mixed up. The line should use this
% syntax, with a two digit number for the VariableRevisionNumber:
% '%%%VariableRevisionNumber = 01'  If the module does not have this
% line, the VariableRevisionNumber is assumed to be 00.  This number
% need only be incremented when a change made to the modules will affect
% a user's previously saved settings. There is a revision number at
% the end of the license info at the top of the m-file for revisions
% that do not affect the user's previously saved settings files.

%%% Reads the current module number, because this is needed to find 
%%% the variable values that the user entered.
CurrentModule = handles.Current.CurrentModuleNumber;
CurrentModuleNum = str2double(CurrentModule);

%textVAR01 = What did you call the images you want to process? 
%defaultVAR01 = OrigBlue
ImageName = char(handles.Settings.VariableValues{CurrentModuleNum,1});

%textVAR02 = What do you want to call the objects identified by this module?
%defaultVAR02 = Nuclei
ObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,2});

%textVAR03 = Size range (in pixels) of objects to include (1,99999 = do not discard any)
%defaultVAR03 = 1,99999
SizeRange = char(handles.Settings.VariableValues{CurrentModuleNum,3});

%textVAR04 = Enter the desired minimum threshold (0 to 1), or "A" to calculate automatically
%defaultVAR04 = A
MinimumThreshold = char(handles.Settings.VariableValues{CurrentModuleNum,4});

%textVAR05 = Enter the threshold adjustment factor (>1 = more stringent, <1 = less stringent)
%defaultVAR05 = 1
ThresholdAdjustmentFactor = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,5}));

%textVAR06 = Block size, in pixels
%defaultVAR06 = 100
BlockSize = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,6}));

%textVAR07 = Do you want to include objects touching the edge (border) of the image? (Yes or No)
%defaultVAR07 = No
IncludeEdge = char(handles.Settings.VariableValues{CurrentModuleNum,7}); 

%textVAR08 = Will you want to save the outlines of the objects (Yes or No)? If yes, use a Save Images module and type "OutlinedOBJECTNAME" in the first box, where OBJECTNAME is whatever you have called the objects identified by this module.
%defaultVAR08 = No
SaveOutlined = char(handles.Settings.VariableValues{CurrentModuleNum,8}); 

%textVAR09 =  Will you want to save the image of the pseudo-colored objects (Yes or No)? If yes, use a Save Images module and type "ColoredOBJECTNAME" in the first box, where OBJECTNAME is whatever you have called the objects identified by this module.
%defaultVAR09 = No
SaveColored = char(handles.Settings.VariableValues{CurrentModuleNum,9}); 

%%%VariableRevisionNumber = 01

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY CALCULATIONS & FILE HANDLING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% Determines what the user entered for the size range.
SizeRangeNumerical = str2num(SizeRange); %#ok We want to ignore MLint error checking for this line.
MinSize = SizeRangeNumerical(1);
MaxSize = SizeRangeNumerical(2);

%%% Reads (opens) the image you want to analyze and assigns it to a variable,
%%% "OrigImageToBeAnalyzed".
%%% Checks whether the image exists in the handles structure.
    if isfield(handles.Pipeline, ImageName) == 0
    error(['Image processing has been canceled. Prior to running the Identify Primary Adaptive Threshold module, you must have previously run a module to load an image. You specified in the Identify Primary Adaptive Threshold module that this image was called ', ImageName, ' which should have produced a field in the handles structure called ', ImageName, '. The Identify Primary Adaptive Threshold module cannot find this image.']);
    end
OrigImageToBeAnalyzed = handles.Pipeline.(ImageName);

%%% Checks that the original image is two-dimensional (i.e. not a color
%%% image), which would disrupt several of the image functions.
if ndims(OrigImageToBeAnalyzed) ~= 2
    error('Image processing was canceled because the Identify Primary Adaptive Threshold module requires an input image that is two-dimensional (i.e. X vs Y), but the image loaded does not fit this requirement.  This may be because the image is a color image.')
end

%%% Checks whether the chosen block size is larger than the image itself.
[m,n] = size(OrigImageToBeAnalyzed);
MinLengthWidth = min(m,n);
if BlockSize >= MinLengthWidth
        error('Image processing was canceled because in the Identify Primary Adaptive Threshold module the selected block size is greater than or equal to the image size itself.')
end

%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%
drawnow

% PROGRAMMING NOTE
% TO TEMPORARILY SHOW IMAGES DURING DEBUGGING: 
% figure, imshow(BlurredImage, []), title('BlurredImage') 
% TO TEMPORARILY SAVE IMAGES DURING DEBUGGING: 
% imwrite(BlurredImage, FileName, FileFormat);
% Note that you may have to alter the format of the image before
% saving.  If the image is not saved correctly, for example, try
% adding the uint8 command:
% imwrite(uint8(BlurredImage), FileName, FileFormat);
% To routinely save images produced by this module, see the help in
% the SaveImages module.

%%% Calculates the MinimumThreshold automatically, if requested.
if strncmp(upper(MinimumThreshold),'A',1) == 1
    GlobalThreshold = CPgraythresh(OrigImageToBeAnalyzed);
    %%% 0.7 seemed to produce good results; there is no theoretical basis
    %%% for choosing that exact number.
    MinimumThreshold = GlobalThreshold*0.7;
else 
    try MinimumThreshold = str2double(MinimumThreshold);
    catch error('The value entered for the minimum threshold in the Identify Primary Adaptive Threshold module was not correct.')
    end
end
%%% Calculates the best block size that prevents padding with zeros, which
%%% would produce edge artifacts. This is based on Matlab's bestblk
%%% function, but changing the minimum of the range searched to be 75% of
%%% the suggested block size rather than 50%. Defines acceptable block
%%% sizes.  m and n were calculated above as the size of the original
%%% image.
MM = floor(BlockSize):-1:floor(min(ceil(m/10),ceil(BlockSize*3/4)));
NN = floor(BlockSize):-1:floor(min(ceil(n/10),ceil(BlockSize*3/4)));
%%% Chooses the acceptable block that has the minimum padding.
[dum,ndx] = min(ceil(m./MM).*MM-m); %#ok We want to ignore MLint error checking for this line.
BestBlockSize(1) = MM(ndx);
[dum,ndx] = min(ceil(n./NN).*NN-n); %#ok We want to ignore MLint error checking for this line.
drawnow
BestBlockSize(2) = NN(ndx);
BestRows = BestBlockSize(1)*ceil(m/BestBlockSize(1));
BestColumns = BestBlockSize(2)*ceil(n/BestBlockSize(2));
RowsToAdd = BestRows - m;
ColumnsToAdd = BestColumns - n;
%%% Pads the image so that the blocks fit properly.
PaddedImage = padarray(OrigImageToBeAnalyzed,[RowsToAdd ColumnsToAdd],'replicate','post');
drawnow
%%% Calculates the threshold for each block in the image.
SmallImageOfThresholds = blkproc(PaddedImage,[BestBlockSize(1) BestBlockSize(2)],@isodata);
%%% Resizes the block-produced image to be the size of the padded image.
%%% Bilinear prevents dipping below zero.
PaddedImageOfThresholds = imresize(SmallImageOfThresholds, size(PaddedImage), 'bilinear');
drawnow
%%% "Crops" the image to get rid of the padding, to make the result the same
%%% size as the original image.
ImageOfThresholds = PaddedImageOfThresholds(1:m,1:n);
%%% Multiplies an adjustment factor against the thresholds to reduce or
%%% increase them all proportionally.
CorrectedImageOfThresholds = ThresholdAdjustmentFactor*ImageOfThresholds;
drawnow
%%% For any of the threshold values that is lower than the user-specified
%%% minimum threshold, set to equal the minimum threshold.  Thus, if there
%%% are no objects within a block (e.g. if cells are very sparse), an
%%% unreasonable threshold will be overridden by the minimum threshold.
MinImageOfThresholds = CorrectedImageOfThresholds;
MinImageOfThresholds(MinImageOfThresholds <= MinimumThreshold) = MinimumThreshold;
%%% Applies the thresholds to the image.
ThresholdedImage = OrigImageToBeAnalyzed;
ThresholdedImage(ThresholdedImage <= MinImageOfThresholds) = 0;
ThresholdedImage(ThresholdedImage > MinImageOfThresholds) = 1;
drawnow
ThresholdedImage = logical(ThresholdedImage);
%%% Holes in the ThresholdedImage image are filled in.
ThresholdedImage = imfill(ThresholdedImage, 'holes');

%%% POTENTIAL IMPROVEMENT TO MAKE:  May want to blur the Image of Thresholds.

%%% Identifies objects in the binary image.
drawnow
PrelimLabelMatrixImage1 = bwlabel(ThresholdedImage);
%%% Finds objects larger and smaller than the user-specified size.
%%% Finds the locations and labels for the pixels that are part of an object.
AreaLocations = find(PrelimLabelMatrixImage1);
drawnow
AreaLabels = PrelimLabelMatrixImage1(AreaLocations);
%%% Creates a sparse matrix with column as label and row as location,
%%% with a 1 at (A,B) if location A has label B.  Summing the columns
%%% gives the count of area pixels with a given label.  E.g. Areas(L) is the
%%% number of pixels with label L.
Areas = full(sum(sparse(AreaLocations, AreaLabels, 1)));
Map = [0,Areas];
AreasImage = Map(PrelimLabelMatrixImage1 + 1);
drawnow
%%% The small objects are overwritten with zeros.
PrelimLabelMatrixImage2 = PrelimLabelMatrixImage1;
PrelimLabelMatrixImage2(AreasImage < MinSize) = 0;
%%% Relabels so that labels are consecutive. This is important for
%%% downstream modules (IdentifySec).
PrelimLabelMatrixImage2 = bwlabel(im2bw(PrelimLabelMatrixImage2,.1));
%%% The large objects are overwritten with zeros.
drawnow
PrelimLabelMatrixImage3 = PrelimLabelMatrixImage2;
if MaxSize ~= 99999
    PrelimLabelMatrixImage3(AreasImage > MaxSize) = 0;
end
%%% Removes objects that are touching the edge of the image, since they
%%% won't be measured properly.
if strncmpi(IncludeEdge,'N',1) == 1
    PrelimLabelMatrixImage4 = imclearborder(PrelimLabelMatrixImage3,8);
else PrelimLabelMatrixImage4 = PrelimLabelMatrixImage3;
end
%%% The PrelimLabelMatrixImage4 is converted to binary.
FinalBinaryPre = im2bw(PrelimLabelMatrixImage4,1);
%%% Holes in the FinalBinaryPre image are filled in.
FinalBinary = imfill(FinalBinaryPre, 'holes');
drawnow
%%% The image is converted to label matrix format. Even if the above step
%%% is excluded (filling holes), it is still necessary to do this in order
%%% to "compact" the label matrix: this way, each number corresponds to an
%%% object, with no numbers skipped.
FinalLabelMatrixImage = bwlabel(FinalBinary);

%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%%
drawnow 

% PROGRAMMING NOTE
% DISPLAYING RESULTS:
% Some calculations produce images that are used only for display or
% for saving to the hard drive, and are not used by downstream
% modules. To speed processing, these calculations are omitted if the
% figure window is closed and the user does not want to save the
% images.

fieldname = ['FigureNumberForModule',CurrentModule];
ThisModuleFigureNumber = handles.Current.(fieldname);
if any(findobj == ThisModuleFigureNumber) == 1 | strncmpi(SaveColored,'Y',1) == 1 | strncmpi(SaveOutlined,'Y',1) == 1
    %%% Calculates the ColoredLabelMatrixImage for displaying in the figure
    %%% window in subplot(2,2,2).
    %%% Note that the label2rgb function doesn't work when there are no objects
    %%% in the label matrix image, so there is an "if".
    if sum(sum(FinalLabelMatrixImage)) >= 1
        ColoredLabelMatrixImage = label2rgb(FinalLabelMatrixImage, 'jet', 'k', 'shuffle');
    else  ColoredLabelMatrixImage = FinalLabelMatrixImage;
    end
    %%% Calculates the PreThresholdedImage for displaying in the figure
    %%% window in subplot(2,2,3).
    PreThresholdedImage = OrigImageToBeAnalyzed;
    PreThresholdedImage(PreThresholdedImage <= CorrectedImageOfThresholds) = 0;
    PreThresholdedImage(PreThresholdedImage > CorrectedImageOfThresholds) = 1;
    %%% Calculates the object outlines, which are overlaid on the original
    %%% image and displayed in figure subplot (2,2,4).
    %%% Creates the structuring element that will be used for dilation.
    StructuringElement = strel('square',3);
    %%% Converts the FinalLabelMatrixImage to binary.
    FinalBinaryImage = im2bw(FinalLabelMatrixImage,1);
    %%% Dilates the FinalBinaryImage by one pixel (8 neighborhood).
    DilatedBinaryImage = imdilate(FinalBinaryImage, StructuringElement);
    %%% Subtracts the FinalBinaryImage from the DilatedBinaryImage,
    %%% which leaves the PrimaryObjectOutlines.
    PrimaryObjectOutlines = DilatedBinaryImage - FinalBinaryImage;
    %%% Overlays the object outlines on the original image.
    ObjectOutlinesOnOriginalImage = OrigImageToBeAnalyzed;
    %%% Determines the grayscale intensity to use for the cell outlines.
    LineIntensity = max(OrigImageToBeAnalyzed(:));
    ObjectOutlinesOnOriginalImage(PrimaryObjectOutlines == 1) = LineIntensity;
% PROGRAMMING NOTE
% DRAWNOW BEFORE FIGURE COMMAND:
% The "drawnow" function executes any pending figure window-related
% commands.  In general, Matlab does not update figure windows until
% breaks between image analysis modules, or when a few select commands
% are used. "figure" and "drawnow" are two of the commands that allow
% Matlab to pause and carry out any pending figure window- related
% commands (like zooming, or pressing timer pause or cancel buttons or
% pressing a help button.)  If the drawnow command is not used
% immediately prior to the figure(ThisModuleFigureNumber) line, then
% immediately after the figure line executes, the other commands that
% have been waiting are executed in the other windows.  Then, when
% Matlab returns to this module and goes to the subplot line, the
% figure which is active is not necessarily the correct one. This
% results in strange things like the subplots appearing in the timer
% window or in the wrong figure window, or in help dialog boxes.
    drawnow
    figure(ThisModuleFigureNumber);
    %%% A subplot of the figure window is set to display the original image.
    subplot(2,2,1); imagesc(OrigImageToBeAnalyzed);colormap(gray);
    title(['Input Image, Image Set # ',num2str(handles.Current.SetBeingAnalyzed)]);
    %%% A subplot of the figure window is set to display the colored label
    %%% matrix image.
    subplot(2,2,2); imagesc(ColoredLabelMatrixImage); title(['Segmented ',ObjectName]);
    %%% A subplot of the figure window is set to display the prethresholded
    %%% image.
    subplot(2,2,3); imagesc(PreThresholdedImage);colormap(gray); title('Without applying minimum threshold');
    %%% A subplot of the figure window is set to display the inverted original
    %%% image with outlines drawn on top.
    subplot(2,2,4); imagesc(ObjectOutlinesOnOriginalImage);colormap(gray); title([ObjectName, ' Outlines on Input Image']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SAVE DATA TO HANDLES STRUCTURE %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

% PROGRAMMING NOTE
% HANDLES STRUCTURE:
%       In CellProfiler (and Matlab in general), each independent
% function (module) has its own workspace and is not able to 'see'
% variables produced by other modules. For data or images to be shared
% from one module to the next, they must be saved to what is called
% the 'handles structure'. This is a variable, whose class is
% 'structure', and whose name is handles. The contents of the handles
% structure are printed out at the command line of Matlab using the
% Tech Diagnosis button. The only variables present in the main
% handles structure are handles to figures and gui elements.
% Everything else should be saved in one of the following
% substructures:
%
% handles.Settings:
%       Everything in handles.Settings is stored when the user uses
% the Save pipeline button, and these data are loaded into
% CellProfiler when the user uses the Load pipeline button. This
% substructure contains all necessary information to re-create a
% pipeline, including which modules were used (including variable
% revision numbers), their setting (variables), and the pixel size.
%   Fields currently in handles.Settings: PixelSize, ModuleNames,
% VariableValues, NumbersOfVariables, VariableRevisionNumbers.
%
% handles.Pipeline:
%       This substructure is deleted at the beginning of the
% analysis run (see 'Which substructures are deleted prior to an
% analysis run?' below). handles.Pipeline is for storing data which
% must be retrieved by other modules. This data can be overwritten as
% each image set is processed, or it can be generated once and then
% retrieved during every subsequent image set's processing, or it can
% be saved for each image set by saving it according to which image
% set is being analyzed, depending on how it will be used by other
% modules. Any module which produces or passes on an image needs to
% also pass along the original filename of the image, named after the
% new image name, so that if the SaveImages module attempts to save
% the resulting image, it can be named by appending text to the
% original file name.
%   Example fields in handles.Pipeline: FileListOrigBlue,
% PathnameOrigBlue, FilenameOrigBlue, OrigBlue (which contains the actual image).
%
% handles.Current:
%       This substructure contains information needed for the main
% CellProfiler window display and for the various modules to
% function. It does not contain any module-specific data (which is in
% handles.Pipeline).
%   Example fields in handles.Current: NumberOfModules,
% StartupDirectory, DefaultOutputDirectory, DefaultImageDirectory,
% FilenamesInImageDir, CellProfilerPathname, ImageToolHelp,
% DataToolHelp, FigureNumberForModule01, NumberOfImageSets,
% SetBeingAnalyzed, TimeStarted, CurrentModuleNumber.
%
% handles.Preferences: 
%       Everything in handles.Preferences is stored in the file
% CellProfilerPreferences.mat when the user uses the Set Preferences
% button. These preferences are loaded upon launching CellProfiler.
% The PixelSize, DefaultImageDirectory, and DefaultOutputDirectory
% fields can be changed for the current session by the user using edit
% boxes in the main CellProfiler window, which changes their values in
% handles.Current. Therefore, handles.Current is most likely where you
% should retrieve this information if needed within a module.
%   Fields currently in handles.Preferences: PixelSize, FontSize,
% DefaultModuleDirectory, DefaultOutputDirectory,
% DefaultImageDirectory.
%
% handles.Measurements:
%       Everything in handles.Measurements contains data specific to each
% image set analyzed for exporting. It is used by the ExportMeanImage
% and ExportCellByCell data tools. This substructure is deleted at the
% beginning of the analysis run (see 'Which substructures are deleted
% prior to an analysis run?' below).
%    Note that two types of measurements are typically made: Object
% and Image measurements.  Object measurements have one number for
% every object in the image (e.g. ObjectArea) and image measurements
% have one number for the entire image, which could come from one
% measurement from the entire image (e.g. ImageTotalIntensity), or
% which could be an aggregate measurement based on individual object
% measurements (e.g. ImageMeanArea).  Use the appropriate prefix to
% ensure that your data will be extracted properly. It is likely that
% Subobject will become a new prefix, when measurements will be
% collected for objects contained within other objects. 
%       Saving measurements: The data extraction functions of
% CellProfiler are designed to deal with only one "column" of data per
% named measurement field. So, for example, instead of creating a
% field of XY locations stored in pairs, they should be split into a
% field of X locations and a field of Y locations. It is wise to
% include the user's input for 'ObjectName' or 'ImageName' as part of
% the fieldname in the handles structure so that multiple modules can
% be run and their data will not overwrite each other.
%   Example fields in handles.Measurements: ImageCountNuclei,
% ObjectAreaCytoplasm, FilenameOrigBlue, PathnameOrigBlue,
% TimeElapsed.
%
% Which substructures are deleted prior to an analysis run?
%       Anything stored in handles.Measurements or handles.Pipeline
% will be deleted at the beginning of the analysis run, whereas
% anything stored in handles.Settings, handles.Preferences, and
% handles.Current will be retained from one analysis to the next. It
% is important to think about which of these data should be deleted at
% the end of an analysis run because of the way Matlab saves
% variables: For example, a user might process 12 image sets of nuclei
% which results in a set of 12 measurements ("ImageTotalNucArea")
% stored in handles.Measurements. In addition, a processed image of
% nuclei from the last image set is left in the handles structure
% ("SegmNucImg"). Now, if the user uses a different module which
% happens to have the same measurement output name "ImageTotalNucArea"
% to analyze 4 image sets, the 4 measurements will overwrite the first
% 4 measurements of the previous analysis, but the remaining 8
% measurements will still be present. So, the user will end up with 12
% measurements from the 4 sets. Another potential problem is that if,
% in the second analysis run, the user runs only a module which
% depends on the output "SegmNucImg" but does not run a module that
% produces an image by that name, the module will run just fine: it
% will just repeatedly use the processed image of nuclei leftover from
% the last image set, which was left in handles.Pipeline.

%%% Saves the segmented image, not edited for objects along the edges or
%%% for size, to the handles structure.
fieldname = ['PrelimSegmented',ObjectName];
handles.Pipeline.(fieldname) = PrelimLabelMatrixImage1;

%%% Saves the segmented image, only edited for small objects, to the
%%% handles structure.
fieldname = ['PrelimSmallSegmented',ObjectName];
handles.Pipeline.(fieldname) = PrelimLabelMatrixImage2;

%%% Saves the final segmented label matrix image to the handles structure.
fieldname = ['Segmented',ObjectName];
handles.Pipeline.(fieldname) = FinalLabelMatrixImage;

%%% Saves images to the handles structure so they can be saved to the hard
%%% drive, if the user requested.
try
    if strncmpi(SaveColored,'Y',1) == 1
        fieldname = ['Colored',ObjectName];
        handles.Pipeline.(fieldname) = ColoredLabelMatrixImage;
    end
    if strncmpi(SaveOutlined,'Y',1) == 1
        fieldname = ['Outlined',ObjectName];
        handles.Pipeline.(fieldname) = ObjectOutlinesOnOriginalImage;
    end
%%% I am pretty sure this try/catch is no longer necessary, but will
%%% leave in just in case.
catch errordlg('The object outlines or colored objects were not calculated by an identify module (possibly because the window is closed) so these images could not be saved to the handles structure. The Save Images module will therefore not function on these images.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ISODATA SUBFUNCTION %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

function level=isodata(I)
%   ISODATA Compute global image threshold using iterative isodata method.
%   LEVEL = ISODATA(I) computes a global threshold (LEVEL) that can be
%   used to convert an intensity image to a binary image with IM2BW. LEVEL
%   is a normalized intensity value that lies in the range [0, 1].
%   This iterative technique for choosing a threshold was developed by Ridler and Calvard .
%   The histogram is initially segmented into two parts using a starting threshold value such as 0 = 2B-1,
%   half the maximum dynamic range.
%   The sample mean (mf,0) of the gray values associated with the foreground pixels and the sample mean (mb,0)
%   of the gray values associated with the background pixels are computed. A new threshold value 1 is now computed
%   as the average of these two sample means. The process is repeated, based upon the new threshold,
%   until the threshold value does not change any more.
% Reference :T.W. Ridler, S. Calvard, Picture thresholding using an iterative selection method,
%            IEEE Trans. System, Man and Cybernetics, SMC-8 (1978) 630-632.

% Convert all N-D arrays into a single column.  Convert to uint8 for
% fastest histogram computation.
I = im2uint8(I(:));

% STEP 1: Compute mean intensity of image from histogram, set T=mean(I)
[counts,N]=imhist(I);
i=1;
mu=cumsum(counts);
T(i)=(sum(N.*counts))/mu(end);
T(i)=round(T(i));

%%% Errors were resulting in the mu2(end) line below if the mean intensity
%%% is zero, so I added the following if statement.
if T(i) == 0
    level = 0;
    return
end

% STEP 2: compute Mean above T (MAT) and Mean below T (MBT) using T from
% step 1
mu2=cumsum(counts(1:T(i)));
MBT=sum(N(1:T(i)).*counts(1:T(i)))/mu2(end);

mu3=cumsum(counts(T(i):end));
MAT=sum(N(T(i):end).*counts(T(i):end))/mu3(end);
i=i+1;
T(i)=round((MAT+MBT)/2);
%%% I added the following line because for some images,
%%% Threshold ends up as an undefined variable if the while function below
%%% does not even get started.
Threshold = T(i);

%%% Errors were resulting in the mu2(end) line below if the mean intensity
%%% is zero, so I added the following if statement.
if T(i) == 0
    level = 0;
    return
end

% STEP 3 to n: repeat step 2 if T(i)~=T(i-1)
while abs(T(i)-T(i-1))>=1
    mu2=cumsum(counts(1:T(i)));
    if mu2(end) == 0
        Threshold=T(i);
        break
    end
    MBT=sum(N(1:T(i)).*counts(1:T(i)))/mu2(end);

    mu3=cumsum(counts(T(i):end));
    if mu3(end) == 0
        Threshold=T(i);
        break
    end
    MAT=sum(N(T(i):end).*counts(T(i):end))/mu3(end);

    i=i+1;
    T(i)=round((MAT+MBT)/2); 
    Threshold=T(i);
end

% Normalize the threshold to the range [i, 1].
level = (Threshold - 1) / (N(end) - 1);
DROP VIEW IF EXISTS [analytics].[rls_UserStudentDataAuthorization];
GO
CREATE VIEW [analytics].[rls_UserStudentDataAuthorization] AS

	-- distinct because a student could be enrolled at two schools in the same district
	SELECT DISTINCT
		Staff.StaffUniqueId AS UserKey,
		Student.StudentUniqueId AS StudentKey
	FROM 
		edfi.Staff
	INNER JOIN 
		edfi.StaffEducationOrganizationAssignmentAssociation
	  ON Staff.StaffUSI = StaffEducationOrganizationAssignmentAssociation.StaffUSI
	INNER JOIN 
		analytics_config.DescriptorMap 
	  ON StaffEducationOrganizationAssignmentAssociation.StaffClassificationDescriptorId = DescriptorMap.DescriptorId
	INNER JOIN 
		analytics_config.DescriptorConstant
	  ON DescriptorMap.DescriptorConstantId = DescriptorConstant.DescriptorConstantId
	INNER JOIN
		edfi.School
	  ON StaffEducationOrganizationAssignmentAssociation.EducationOrganizationId = School.LocalEducationAgencyId
	INNER JOIN
		edfi.StudentSchoolAssociation
	  ON School.SchoolId = StudentSchoolAssociation.SchoolId
	INNER JOIN
		edfi.Student
	  ON StudentSchoolAssociation.StudentUSI = Student.StudentUSI
	WHERE 
		DescriptorConstant.ConstantName = 'AuthorizationScope.District'
		AND StaffEducationOrganizationAssignmentAssociation.EndDate IS NULL
		AND StudentSchoolAssociation.ExitWithdrawDate IS NULL

UNION ALL

	SELECT 
		Staff.StaffUniqueId AS UserKey,
		Student.StudentUniqueId AS StudentKey
	FROM 
		edfi.Staff
	INNER JOIN 
		edfi.StaffEducationOrganizationAssignmentAssociation
	  ON Staff.StaffUSI = StaffEducationOrganizationAssignmentAssociation.StaffUSI
	INNER JOIN 
		analytics_config.DescriptorMap
	  ON StaffEducationOrganizationAssignmentAssociation.StaffClassificationDescriptorId = DescriptorMap.DescriptorId
	INNER JOIN 
		analytics_config.DescriptorConstant
	  ON DescriptorMap.DescriptorConstantId = DescriptorConstant.DescriptorConstantId
	INNER JOIN
		edfi.StudentSchoolAssociation
	  ON StaffEducationOrganizationAssignmentAssociation.EducationOrganizationId = StudentSchoolAssociation.SchoolId
	INNER JOIN
		edfi.Student
	  ON StudentSchoolAssociation.StudentUSI = Student.StudentUSI
	WHERE 
		DescriptorConstant.ConstantName = 'AuthorizationScope.School'
		AND StaffEducationOrganizationAssignmentAssociation.EndDate IS NULL
		AND StudentSchoolAssociation.ExitWithdrawDate IS NULL

UNION ALL

	-- distinct because a student could be in two sections taught by same teacher
	SELECT DISTINCT
		Staff.StaffUniqueId AS UserKey,
		Student.StudentUniqueId AS StudentKey
	FROM 
		edfi.Staff
	INNER JOIN 
		edfi.StaffEducationOrganizationAssignmentAssociation
	  ON Staff.StaffUSI = StaffEducationOrganizationAssignmentAssociation.StaffUSI
	INNER JOIN 
		analytics_config.DescriptorMap
	  ON StaffEducationOrganizationAssignmentAssociation.StaffClassificationDescriptorId = DescriptorMap.DescriptorId
	INNER JOIN 
		analytics_config.DescriptorConstant
	  ON DescriptorMap.DescriptorConstantId = DescriptorConstant.DescriptorConstantId
	INNER JOIN 
		edfi.StaffSectionAssociation
	  ON StaffEducationOrganizationAssignmentAssociation.StaffUSI = StaffSectionAssociation.StaffUSI
		AND StaffEducationOrganizationAssignmentAssociation.EducationOrganizationId = StaffSectionAssociation.SchoolId
	INNER JOIN 
		edfi.StudentSectionAssociation
	  ON StudentSectionAssociation.LocalCourseCode = StaffSectionAssociation.LocalCourseCode
		AND StudentSectionAssociation.SchoolId = StaffSectionAssociation.SchoolId
		AND StudentSectionAssociation.SchoolYear = StaffSectionAssociation.SchoolYear
		AND StudentSectionAssociation.SectionIdentifier = StaffSectionAssociation.SectionIdentifier
		AND StudentSectionAssociation.SessionName = StaffSectionAssociation.SessionName
	INNER JOIN
		edfi.Student
	  ON StudentSectionAssociation.StudentUSI = Student.StudentUSI
	WHERE 
		DescriptorConstant.ConstantName = 'AuthorizationScope.Section'
		AND StaffEducationOrganizationAssignmentAssociation.EndDate IS NULL
		AND (StudentSectionAssociation.EndDate IS NULL
		  OR StudentSectionAssociation.EndDate >= GETDATE())
GO



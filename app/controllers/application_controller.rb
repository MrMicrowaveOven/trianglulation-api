class ApplicationController < ActionController::API
    RADIUS_OF_EARTH = 3963
    def index
        lat1, lng1, distance1 = params['lat1'].to_f, params['lng1'].to_f, params['distance1'].to_f
        lat2, lng2, distance2 = params['lat2'].to_f, params['lng2'].to_f, params['distance2'].to_f
        lat3, lng3, distance3 = params['lat3'].to_f, params['lng3'].to_f, params['distance3'].to_f
        equidistant_points1 = get_equidistant_points(lat1, lng1, distance1)
        equidistant_points2 = get_equidistant_points(lat2, lng2, distance2)
        equidistant_points3 = get_equidistant_points(lat3, lng3, distance3)

        closest_points_for_1_and_2 = get_closest_points(equidistant_points1, equidistant_points2)
        closest_points_for_all_3 = get_closest_points(closest_points_for_1_and_2, equidistant_points3)
        closest_point = get_midpoint(closest_points_for_all_3[0], closest_points_for_all_3[1])

        render json: { closest_point: closest_point }
    end

    private

    def get_equidistant_points(lat, lng, distance)
        vert_points = get_vert_points(lat, lng, distance)
        hor_points = get_hor_points(lat, lng, distance)

        north_lat = vert_points[0][0]
        east_lng = hor_points[1][1]
        vert_angular_distance = north_lat - lat
        hor_angular_distance = east_lng - lng
        angular_points = get_angular_points(lat, lng, vert_angular_distance, hor_angular_distance)
        vert_points + hor_points + angular_points
    end

    def get_angular_points(lat, lng, vert_angular_distance, hor_angular_distance)
        points = []
        90.times do |i|
            points += get_points_at_theta(lat, lng, vert_angular_distance, hor_angular_distance, i)
        end
        points
    end

    def get_vert_points(lat, lng, distance)
        degrees_to_move_radians = distance / RADIUS_OF_EARTH
        degrees_to_move = degrees_to_move_radians * 180 / Math::PI
        [[lat + degrees_to_move, lng], [lat - degrees_to_move, lng]]
    end

    def get_hor_points(lat, lng, distance)
        lat_in_radians = lat * Math::PI / 180
        radius_at_latitude = RADIUS_OF_EARTH * Math.cos(lat_in_radians)
        degrees_to_move_radians = distance / radius_at_latitude
        degrees_to_move = degrees_to_move_radians * 180 / Math::PI
        [[lat, lng - degrees_to_move], [lat, lng + degrees_to_move]]
    end

    def get_points_at_theta(lat, lng, vert_angular_distance, hor_angular_distance, theta)
        theta_in_radians = theta * Math::PI / 180
        vert_angular_distance_of_theta = vert_angular_distance * Math.sin(theta_in_radians)
        hor_angular_distance_of_theta = hor_angular_distance * Math.cos(theta_in_radians)
        [
            [lat + vert_angular_distance_of_theta, lng + hor_angular_distance_of_thevert_angular_distance_of_theta],
            [lat - vert_angular_distance_of_theta, lng + hor_angular_distance_of_thevert_angular_distance_of_theta],
            [lat - vert_angular_distance_of_theta, lng - hor_angular_distance_of_thevert_angular_distance_of_theta],
            [lat + vert_angular_distance_of_theta, lng - hor_angular_distance_of_thevert_angular_distance_of_theta],
        ]
    end

    def get_distance(lat1, lng1, lat2, lng2)
        vert_angle_difference = (lat1 - lat2).abs
        vert_angle_difference_radians = vert_angle_difference * Math::PI / 180
        vert_distance = RADIUS_OF_EARTH * vert_angle_difference_radians

        hor_angular_distance = (lng1 - lng2).abs
        hor_angular_distance_radians = hor_angular_distance * Math::PI / 180

        average_lat = (lat1 + lat2)/ 2
        average_lat_radians = average_lat * Math::PI / 180
        radius_at_latitude = RADIUS_OF_EARTH * Math.cos(average_lat_radians)
        hor_distance = radius_at_latitude * hor_angular_distance_radians

        Math.sqrt(vert_distance**2 + hor_distance**2)
    end

    def get_midpoint(point1, point2)
        [(point1[0] + point2[0])/2, (point1[1] + point2[1])/2]
    end

    def get_closest_points(equidistant_points1, equidistant_points2)
        smallest_distance = 10000
        closest_points = []
        equidistant_points1.each do |point1|
            equidistant_points2.each do |point2|
                distance = get_distance(point1[0], point1[1], point2[0], point2[1])
                if distance < smallest_distance
                    smallest_distance = distance
                    closest_points = [point1, point2]
                end
            end
        end
        closest_points
    end
end